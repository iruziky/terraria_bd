def list_players(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT name, hp || '/' || max_hp, mana || '/' || max_mana, class, team,
                   is_alive, coins, general_stats ->> 'defense'
            FROM player
            ORDER BY id_player
            """
        )
        return cur.fetchall()


def find_by_name(conn, table, id_column, name):
    with conn.cursor() as cur:
        cur.execute(
            f"SELECT {id_column}, name FROM {table} WHERE name ILIKE %s ORDER BY name",
            (f"%{name}%",),
        )
        matches = cur.fetchall()
    exact = [match for match in matches if match[1].lower() == name.lower()]
    return exact or matches


def player_inventory(conn, id_player):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT inventory.type, inventory_item.slot, item.name,
                   inventory_item.quantity, inventory_item.equipped
            FROM inventory
            INNER JOIN inventory_item ON inventory_item.id_inventory = inventory.id_inventory
            INNER JOIN item ON item.id_item = inventory_item.id_item
            WHERE inventory.id_player = %s
            ORDER BY CASE inventory.type
                         WHEN 'main' THEN 1 WHEN 'ammo' THEN 2 WHEN 'equipment' THEN 3
                         WHEN 'piggy_bank' THEN 4 ELSE 5
                     END,
                     inventory_item.slot
            """,
            (id_player,),
        )
        return cur.fetchall()


def biome_enemies(conn, id_biome):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT enemy.name, enemy.hp, enemy.defense, ai.name
            FROM enemy_biome
            INNER JOIN enemy ON enemy.id_enemy = enemy_biome.id_enemy
            INNER JOIN ai ON ai.id_ai = enemy.id_ai
            WHERE enemy_biome.id_biome = %s
            ORDER BY enemy.name
            """,
            (id_biome,),
        )
        return cur.fetchall()


def item_sources(conn, id_item):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT 'drop', enemy.name,
                   round(enemy_drop.chance * 100, 2) || '%',
                   enemy_drop.min_quantity || '-' || enemy_drop.max_quantity
            FROM enemy_drop
            INNER JOIN enemy ON enemy.id_enemy = enemy_drop.id_enemy
            WHERE enemy_drop.id_item = %s
            UNION
            SELECT 'receita', coalesce(station.name, 'à mão'), '100%',
                   recipe.result_quantity::text
            FROM recipe
            LEFT JOIN item AS station ON station.id_item = recipe.id_station
            WHERE recipe.id_result = %s
            ORDER BY 1, 2
            """,
            (id_item, id_item),
        )
        return cur.fetchall()
