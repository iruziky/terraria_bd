import psycopg2
from tabulate import tabulate

from db import connect


def show(headers, rows):
    if rows:
        print(tabulate(rows, headers=headers, tablefmt="simple_outline"))
    else:
        print("Nenhum resultado.")


MENU = []


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
