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
