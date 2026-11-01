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
        (name, hp, mana, player_class, team, "sim" if alive else "não", format_coins(coins), defense)
        for name, hp, mana, player_class, team, alive, coins, defense in operacoes.list_players(conn)
    ]
    show(["Jogador", "Vida", "Mana", "Classe", "Time", "Vivo", "Moedas", "Defesa"], rows)


def ask(conn, table, id_column, label):
    name = input(f"{label}: ").strip()
    matches = operacoes.find_by_name(conn, table, id_column, name)
    if not matches:
        print(f"Nenhum resultado para '{name}'.")
        return None
    if len(matches) > 1:
        print("Mais de um resultado: " + ", ".join(match[1] for match in matches))
        return None
    return matches[0]


def show_inventory(conn):
    player = ask(conn, "player", "id_player", "Jogador")
    if player:
        rows = [
            (inventory, slot, item, quantity, "sim" if equipped else "")
            for inventory, slot, item, quantity, equipped in operacoes.player_inventory(conn, player[0])
        ]
        show(["Inventário", "Slot", "Item", "Qtd", "Equipado"], rows)


def show_biome_enemies(conn):
    biome = ask(conn, "biome", "id_biome", "Bioma")
    if biome:
        show(["Inimigo", "Vida", "Defesa", "IA"], operacoes.biome_enemies(conn, biome[0]))


def show_item_sources(conn):
    item = ask(conn, "item", "id_item", "Item")
    if item:
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
        _, result_quantity, station, _, _ = ingredients[0]
        print(f"\n{result_quantity}x {item[1]} (estação: {station})")
        show(["Ingrediente", "Qtd"], [(name, quantity) for _, _, _, name, quantity in ingredients])


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
    quantity, missing = result
    if quantity:
        print(f"{player[1]} fabricou {quantity}x {item[1]}.")
    else:
        print(f"{player[1]} não tem os ingredientes necessários no inventário principal:")
        show(["Ingrediente", "Precisa", "Tem"], missing)


MENU = [
    ("Listar jogadores", list_players),
    ("Ver inventário de um jogador", show_inventory),
    ("Inimigos de um bioma", show_biome_enemies),
    ("Como obter um item", show_item_sources),
    ("Ver receita de um item", show_recipes),
    ("Fabricar item", craft_item),
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
