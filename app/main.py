import psycopg2
from tabulate import tabulate

import operacoes
from db import connect


def show(headers, rows):
    if rows:
        print(tabulate(rows, headers=headers, tablefmt="simple_outline"))
    else:
        print("Nenhum resultado.")


def format_coins(copper):
    parts = []
    for name, value in (("platina", 1000000), ("ouro", 10000), ("prata", 100), ("cobre", 1)):
        amount, copper = divmod(copper, value)
        if amount:
            parts.append(f"{amount} {name}")
    return " ".join(parts) or "0"


def list_players(conn):
    rows = [
        (id_player, name, hp, mana, player_class, team, "sim" if alive else "não", format_coins(coins), defense)
        for id_player, name, hp, mana, player_class, team, alive, coins, defense in operacoes.list_players(conn)
    ]
    show(["Id", "Jogador", "Vida", "Mana", "Classe", "Time", "Vivo", "Moedas", "Defesa"], rows)


def ask(conn, table, id_column, label):
    name = input(f"{label} (nome ou id): ").strip()
    if name.isdigit():
        matches = operacoes.find_by_id(conn, table, id_column, int(name))
    else:
        matches = operacoes.find_by_name(conn, table, id_column, name)
    if not matches:
        print(f"Nenhum resultado para '{name}'.")
        return None
    if len(matches) > 1:
        print("Mais de um resultado. Digite o id de um deles:")
        show(["Id", label], matches)
        return None
    print(f"  → {label}: {matches[0][1]} (id {matches[0][0]})")
    return matches[0]


def show_inventory(conn):
    player = ask(conn, "player", "id_player", "Jogador")
    if player:
        print(f"\nInventário de {player[1]}:")
        rows = [
            (inventory, slot, id_item, item, quantity, "sim" if equipped else "")
            for inventory, slot, id_item, item, quantity, equipped in operacoes.player_inventory(conn, player[0])
        ]
        show(["Inventário", "Slot", "Id", "Item", "Qtd", "Equipado"], rows)


def show_biome_enemies(conn):
    biome = ask(conn, "biome", "id_biome", "Bioma")
    if biome:
        print(f"\nInimigos que habitam {biome[1]}:")
        show(["Id", "Inimigo", "Vida", "Defesa", "IA"], operacoes.biome_enemies(conn, biome[0]))


def show_item_sources(conn):
    item = ask(conn, "item", "id_item", "Item")
    if item:
        print(f"\nFormas de obter {item[1]}:")
        show(["Forma", "Origem", "Chance", "Qtd"], operacoes.item_sources(conn, item[0]))


def show_recipes(conn):
    item = ask(conn, "item", "id_item", "Item")
    if not item:
        return
    rows = operacoes.recipes(conn, item[0])
    if not rows:
        print(f"{item[1]} não tem receita.")
        return
    for id_recipe in dict.fromkeys(row[0] for row in rows):
        ingredients = [row for row in rows if row[0] == id_recipe]
        _, result_quantity, station, _, _, _ = ingredients[0]
        print(f"\nReceita: {result_quantity}x {item[1]} (estação: {station})")
        show(["Id", "Ingrediente", "Qtd"], [row[3:] for row in ingredients])


def craft_item(conn):
    player = ask(conn, "player", "id_player", "Jogador")
    item = player and ask(conn, "item", "id_item", "Item")
    if not item:
        return
    try:
        result = operacoes.craft(conn, player[0], item[0])
    except operacoes.InventoryFullError:
        print("Inventário principal cheio.")
        return
    if result is None:
        print(f"{item[1]} não tem receita.")
        return
    if not result["quantity"]:
        print(f"{player[1]} não pode fabricar {item[1]}: faltam ingredientes no inventário principal.")
        show(["Ingrediente", "Precisa", "Tem"], result["missing"])
        return
    print(f"{player[1]} fabricou {result['quantity']}x {item[1]} (estação: {result['station']}).")
    print("Ingredientes gastos: " + ", ".join(f"{quantity}x {name}" for name, quantity in result["consumed"]))
    print(f"{item[1]} foi guardado no slot {result['slot']} do inventário principal (agora tem {result['total']}).")


def fight_enemy(conn):
    player = ask(conn, "player", "id_player", "Jogador")
    enemy = player and ask(conn, "enemy", "id_enemy", "Inimigo")
    if not enemy:
        return
    try:
        result = operacoes.fight_enemy(conn, player[0], enemy[0])
    except operacoes.DeadPlayerError:
        print(f"{player[1]} está morto e não pode lutar.")
        return
    except operacoes.NoWeaponError:
        print(f"{player[1]} não tem nenhuma arma no inventário principal.")
        return
    except operacoes.InventoryFullError:
        print("Inventário principal cheio. A luta foi cancelada.")
        return
    name, enemy_name = player[1], enemy[1]
    print(
        f"\n{name} ({result['start_hp']}/{result['max_hp']} de vida, defesa {result['defense']}) "
        f"enfrenta {enemy_name} ({result['enemy_hp']} de vida, defesa {result['enemy_defense']}, "
        f"dano {result['enemy_damage']}) usando {result['weapon']} (dano {result['weapon_damage']})."
    )
    turn = 0
    for attacker, hit, critical, remaining in result["log"]:
        if attacker == "player":
            turn += 1
            extra = " (crítico!)" if critical else ""
            print(f"Turno {turn}: {name} causa {hit} de dano{extra}. {enemy_name}: {remaining}/{result['enemy_hp']}.")
        else:
            print(f"{' ' * len(f'Turno {turn}: ')}{enemy_name} causa {hit} de dano. {name}: {remaining}/{result['max_hp']}.")
    if not result["won"]:
        print(f"\n{name} foi derrotado por {enemy_name} e morreu. Nenhum item foi obtido.")
        return
    print(f"\n{name} derrotou {enemy_name} em {turn} turnos e ficou com {result['hp']}/{result['max_hp']} de vida.")
    if not result["drops"]:
        print(f"{enemy_name} não dropou nenhum item.")
    for item, quantity, slot, total in result["drops"]:
        print(f"Drop: {quantity}x {item}, guardado no slot {slot} do inventário principal (agora tem {total}).")


def list_biomes(conn):
    show(["Id", "Bioma", "Inimigos"], operacoes.list_biomes(conn))


def list_items(conn):
    show(["Id", "Item", "Tipo", "Raridade", "Dano"], operacoes.list_items(conn))


def list_enemies(conn):
    show(["Id", "Inimigo", "Vida", "Defesa", "IA", "Biomas"], operacoes.list_enemies(conn))


MENU = [
    ("Listar jogadores", list_players),
    ("Listar biomas", list_biomes),
    ("Listar itens", list_items),
    ("Listar inimigos", list_enemies),
    ("Ver inventário de um jogador", show_inventory),
    ("Inimigos de um bioma", show_biome_enemies),
    ("Como obter um item", show_item_sources),
    ("Ver receita de um item", show_recipes),
    ("Fabricar item", craft_item),
    ("Lutar contra um inimigo", fight_enemy),
]


def main():
    conn = connect()
    while True:
        print()
        for number, (label, _) in enumerate(MENU, 1):
            print(f"{number}. {label}")
        print("0. Sair")
        try:
            option = input("> ").strip()
        except EOFError:
            break
        if option == "0":
            break
        if not option.isdigit() or not 1 <= int(option) <= len(MENU):
            print("Opção inválida.")
            continue
        try:
            MENU[int(option) - 1][1](conn)
        except psycopg2.Error as error:
            conn.rollback()
            print(f"Erro no banco: {error}")
    conn.close()


if __name__ == "__main__":
    main()
