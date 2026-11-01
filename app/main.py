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


MENU = [
    ("Listar jogadores", list_players),
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
