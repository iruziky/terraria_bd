import math
import random


def list_players(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT id_player, name, hp || '/' || max_hp, mana || '/' || max_mana, class, team,
                   is_alive, coins, general_stats ->> 'defense'
            FROM player
            ORDER BY id_player
            """
        )
        return cur.fetchall()


def find_by_id(conn, table, id_column, id_value):
    with conn.cursor() as cur:
        cur.execute(f"SELECT {id_column}, name FROM {table} WHERE {id_column} = %s", (id_value,))
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
            SELECT inventory.type, inventory_item.slot, item.id_item, item.name,
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
            SELECT enemy.id_enemy, enemy.name, enemy.hp, enemy.defense, ai.name
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
                   round(enemy_drop.chance * 100, 2) || '%%',
                   enemy_drop.min_quantity || '-' || enemy_drop.max_quantity
            FROM enemy_drop
            INNER JOIN enemy ON enemy.id_enemy = enemy_drop.id_enemy
            WHERE enemy_drop.id_item = %s
            UNION
            SELECT 'receita', coalesce(station.name, 'à mão'), '100%%',
                   recipe.result_quantity::text
            FROM recipe
            LEFT JOIN item AS station ON station.id_item = recipe.id_station
            WHERE recipe.id_result = %s
            ORDER BY 1, 2
            """,
            (id_item, id_item),
        )
        return cur.fetchall()


def recipes(conn, id_item):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT recipe.id_recipe, recipe.result_quantity, coalesce(station.name, 'à mão'),
                   ingredient.id_item, ingredient.name, recipe_ingredient.quantity
            FROM recipe
            INNER JOIN recipe_ingredient ON recipe_ingredient.id_recipe = recipe.id_recipe
            INNER JOIN item AS ingredient ON ingredient.id_item = recipe_ingredient.id_ingredient
            LEFT JOIN item AS station ON station.id_item = recipe.id_station
            WHERE recipe.id_result = %s
            ORDER BY recipe.id_recipe, ingredient.name
            """,
            (id_item,),
        )
        return cur.fetchall()


class InventoryFullError(Exception):
    pass


def main_inventory(cur, id_player):
    cur.execute(
        "SELECT id_inventory, capacity FROM inventory WHERE id_player = %s AND type = 'main'",
        (id_player,),
    )
    return cur.fetchone()


def add_item(cur, id_inventory, capacity, id_item, quantity):
    cur.execute(
        "SELECT slot FROM inventory_item WHERE id_inventory = %s AND id_item = %s ORDER BY slot LIMIT 1",
        (id_inventory, id_item),
    )
    row = cur.fetchone()
    if row:
        cur.execute(
            """
            UPDATE inventory_item SET quantity = quantity + %s
            WHERE id_inventory = %s AND slot = %s
            RETURNING slot, quantity
            """,
            (quantity, id_inventory, row[0]),
        )
        return cur.fetchone()
    cur.execute("SELECT slot FROM inventory_item WHERE id_inventory = %s", (id_inventory,))
    used = {slot for (slot,) in cur.fetchall()}
    free = next((slot for slot in range(capacity) if slot not in used), None)
    if free is None:
        raise InventoryFullError
    cur.execute(
        "INSERT INTO inventory_item (id_inventory, slot, id_item, quantity) VALUES (%s, %s, %s, %s)",
        (id_inventory, free, id_item, quantity),
    )
    return free, quantity


def remove_item(cur, id_inventory, id_item, quantity):
    cur.execute(
        "SELECT slot, quantity FROM inventory_item WHERE id_inventory = %s AND id_item = %s ORDER BY slot",
        (id_inventory, id_item),
    )
    for slot, available in cur.fetchall():
        if quantity == 0:
            break
        taken = min(available, quantity)
        if taken == available:
            cur.execute(
                "DELETE FROM inventory_item WHERE id_inventory = %s AND slot = %s",
                (id_inventory, slot),
            )
        else:
            cur.execute(
                "UPDATE inventory_item SET quantity = quantity - %s WHERE id_inventory = %s AND slot = %s",
                (taken, id_inventory, slot),
            )
        quantity -= taken


def missing_ingredients(cur, id_inventory, id_recipe):
    cur.execute(
        """
        SELECT item.name, recipe_ingredient.quantity, coalesce(sum(inventory_item.quantity), 0)
        FROM recipe_ingredient
        INNER JOIN item ON item.id_item = recipe_ingredient.id_ingredient
        LEFT JOIN inventory_item ON inventory_item.id_item = recipe_ingredient.id_ingredient
                                AND inventory_item.id_inventory = %s
        WHERE recipe_ingredient.id_recipe = %s
        GROUP BY item.name, recipe_ingredient.quantity
        HAVING coalesce(sum(inventory_item.quantity), 0) < recipe_ingredient.quantity
        """,
        (id_inventory, id_recipe),
    )
    return cur.fetchall()


def craft(conn, id_player, id_item):
    with conn, conn.cursor() as cur:
        id_inventory, capacity = main_inventory(cur, id_player)
        cur.execute(
            """
            SELECT recipe.id_recipe, recipe.result_quantity, coalesce(station.name, 'à mão')
            FROM recipe
            LEFT JOIN item AS station ON station.id_item = recipe.id_station
            WHERE recipe.id_result = %s
            ORDER BY recipe.id_recipe
            """,
            (id_item,),
        )
        options = cur.fetchall()
        if not options:
            return None
        missing = []
        for id_recipe, result_quantity, station in options:
            missing = missing_ingredients(cur, id_inventory, id_recipe)
            if missing:
                continue
            cur.execute(
                """
                SELECT recipe_ingredient.id_ingredient, item.name, recipe_ingredient.quantity
                FROM recipe_ingredient
                INNER JOIN item ON item.id_item = recipe_ingredient.id_ingredient
                WHERE recipe_ingredient.id_recipe = %s
                """,
                (id_recipe,),
            )
            consumed = cur.fetchall()
            for id_ingredient, _, quantity in consumed:
                remove_item(cur, id_inventory, id_ingredient, quantity)
            slot, total = add_item(cur, id_inventory, capacity, id_item, result_quantity)
            return {
                "quantity": result_quantity,
                "station": station,
                "consumed": [(name, quantity) for _, name, quantity in consumed],
                "slot": slot,
                "total": total,
                "missing": [],
            }
        return {"quantity": 0, "missing": missing}


class DeadPlayerError(Exception):
    pass


class NoWeaponError(Exception):
    pass


def roll_damage(damage, defense):
    varied = round(damage * random.uniform(0.85, 1.15))
    return max(1, math.floor(varied - defense * 0.5))


def fight_enemy(conn, id_player, id_enemy):
    with conn, conn.cursor() as cur:
        cur.execute(
            """
            SELECT hp, is_alive, crit_chance, coalesce((general_stats ->> 'defense')::int, 0)
            FROM player
            WHERE id_player = %s
            """,
            (id_player,),
        )
        hp, alive, crit_chance, defense = cur.fetchone()
        if not alive:
            raise DeadPlayerError
        cur.execute(
            """
            SELECT item.name, item.damage
            FROM inventory
            INNER JOIN inventory_item ON inventory_item.id_inventory = inventory.id_inventory
            INNER JOIN item ON item.id_item = inventory_item.id_item
            WHERE inventory.id_player = %s AND inventory.type = 'main' AND item.type = 'weapon'
            ORDER BY item.damage DESC
            LIMIT 1
            """,
            (id_player,),
        )
        weapon = cur.fetchone()
        if weapon is None:
            raise NoWeaponError
        weapon_name, weapon_damage = weapon
        cur.execute("SELECT hp, defense, damage FROM enemy WHERE id_enemy = %s", (id_enemy,))
        enemy_hp, enemy_defense, enemy_damage = cur.fetchone()
        turns = dealt = taken = crits = 0
        while True:
            turns += 1
            hit = roll_damage(weapon_damage, enemy_defense)
            if random.random() < crit_chance:
                hit *= 2
                crits += 1
            dealt += hit
            enemy_hp -= hit
            if enemy_hp <= 0:
                break
            hit = min(hp, roll_damage(enemy_damage, defense))
            taken += hit
            hp -= hit
            if hp == 0:
                break
        cur.execute(
            "UPDATE player SET hp = %s, is_alive = %s WHERE id_player = %s",
            (hp, hp > 0, id_player),
        )
        obtained = []
        if hp > 0:
            id_inventory, capacity = main_inventory(cur, id_player)
            cur.execute(
                """
                SELECT enemy_drop.id_item, item.name, enemy_drop.chance,
                       enemy_drop.min_quantity, enemy_drop.max_quantity
                FROM enemy_drop
                INNER JOIN item ON item.id_item = enemy_drop.id_item
                WHERE enemy_drop.id_enemy = %s
                """,
                (id_enemy,),
            )
            for id_item, name, chance, minimum, maximum in cur.fetchall():
                if random.random() < float(chance):
                    quantity = random.randint(minimum, maximum)
                    add_item(cur, id_inventory, capacity, id_item, quantity)
                    obtained.append((name, quantity))
        return {
            "won": hp > 0,
            "weapon": weapon_name,
            "turns": turns,
            "dealt": dealt,
            "crits": crits,
            "taken": taken,
            "hp": hp,
            "drops": obtained,
        }


def list_biomes(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT biome.id_biome, biome.name, count(enemy_biome.id_enemy)
            FROM biome
            LEFT JOIN enemy_biome ON enemy_biome.id_biome = biome.id_biome
            GROUP BY biome.id_biome, biome.name
            ORDER BY biome.id_biome
            """
        )
        return cur.fetchall()


def list_items(conn):
    with conn.cursor() as cur:
        cur.execute("SELECT id_item, name, type, rarity, damage FROM item ORDER BY id_item")
        return cur.fetchall()


def list_enemies(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT enemy.id_enemy, enemy.name, enemy.hp, enemy.defense, ai.name,
                   string_agg(biome.name, ', ' ORDER BY biome.name)
            FROM enemy
            INNER JOIN ai ON ai.id_ai = enemy.id_ai
            LEFT JOIN enemy_biome ON enemy_biome.id_enemy = enemy.id_enemy
            LEFT JOIN biome ON biome.id_biome = enemy_biome.id_biome
            GROUP BY enemy.id_enemy, enemy.name, enemy.hp, enemy.defense, ai.name
            ORDER BY enemy.id_enemy
            """
        )
        return cur.fetchall()
