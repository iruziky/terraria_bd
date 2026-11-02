# Banco de Dados — Terraria

Projeto da disciplina de Banco de Dados: modelagem e implementação de um banco que representa parte do universo do jogo Terraria.

**Grupo:** Iruziky Araujo de Medeiros, Heitor Gabriel de Carvalho Borges e Davi Alves do Nascimento.

## Minimundo

O banco representa jogadores, seus inventários e itens, além de inimigos, biomas, padrões de IA, drops e receitas de fabricação.

Cada jogador tem atributos como vida, mana, classe e time, e possui um inventário de cada tipo (principal, Piggy Bank, cofre, munição e equipamento). Cada item guardado ocupa um slot e tem uma quantidade.

Cada inimigo segue um padrão de IA, habita um ou mais biomas e pode dropar vários itens, cada um com chance e quantidade mínima e máxima. Um item pode ser fabricado por receitas, que exigem ingredientes e, em geral, uma estação de crafting (que também é um item).

Os dados do jogo foram retirados da [Terraria Wiki](https://terraria.wiki.gg) (versão PC, modo Classic, pré-Hardmode). Os jogadores e inventários são fictícios.

## Estrutura

```
docs/
  iteracao1/               entrega do trabalho 1 (minimundo, diagrama UML e justificativas)
  iteracao2/der.md         DER da segunda iteração (Mermaid)
  mudancas.md              mudanças da primeira para a segunda iteração
sql/
  01_schema.sql            criação das tabelas e restrições
  02_dados.sql             população do banco
  03_consultas.sql         exemplos de consultas
app/                       aplicação de terminal em Python
docker-compose.yml         PostgreSQL 16 já criado e populado
```

## DER

O diagrama completo, com as cardinalidades, está em [`docs/iteracao2/der.md`](docs/iteracao2/der.md). As mudanças em relação ao trabalho 1 (nomenclatura, relação N:N entre inimigos e biomas, estação como item, restrições etc.) estão explicadas em [`docs/mudancas.md`](docs/mudancas.md).

## Como rodar o banco

### Com Docker (recomendado)

```bash
docker compose up -d
```

O container cria o banco `terraria` e executa `01_schema.sql` e `02_dados.sql` automaticamente. Ele fica disponível em `localhost:5433` (usuário `postgres`, senha `postgres`). A porta 5433 evita conflito com um PostgreSQL já instalado na máquina.

Para recriar o banco do zero (descartando alterações feitas pela aplicação):

```bash
docker compose down -v && docker compose up -d
```

### Com um PostgreSQL local

```bash
sudo -u postgres createdb terraria
sudo -u postgres psql -d terraria -f sql/01_schema.sql
sudo -u postgres psql -d terraria -f sql/02_dados.sql
```

Nesse caso, a aplicação precisa das variáveis `PGPORT=5432` e, se necessário, `PGUSER` e `PGPASSWORD`.

## Exemplos de consultas

```bash
PGPASSWORD=postgres psql -h localhost -p 5433 -U postgres -d terraria -f sql/03_consultas.sql
```

O arquivo tem consultas comentadas que cobrem seleção, projeção e renomeação, junções, união, interseção, subtração, produto cartesiano, divisão, tabelas temporárias, `UPDATE`, `ALTER TABLE` e uma demonstração das restrições (comandos que falham de propósito). As consultas que alteram dados ficam dentro de `BEGIN ... ROLLBACK`, então o script pode ser executado várias vezes.

## Aplicação

```bash
python3 -m venv .venv
.venv/bin/pip install -r app/requirements.txt
cd app && ../.venv/bin/python main.py
```

Menu, com as listagens primeiro e depois as consultas e ações:

1. **Listar jogadores**: vida, mana, classe, time, moedas e defesa.
2. **Listar biomas**: todos os biomas, com a quantidade de inimigos de cada um.
3. **Listar itens**: todos os itens, com tipo, raridade e dano.
4. **Listar inimigos**: todos os inimigos, com vida, defesa, IA e biomas.
5. **Ver inventário de um jogador**: todos os inventários, slot a slot.
6. **Inimigos de um bioma.**
7. **Como obter um item**: drops (com chance) e receitas.
8. **Ver receita de um item**: ingredientes e estação.
9. **Fabricar item**: confere os ingredientes no inventário principal, consome e adiciona o resultado numa única transação.
10. **Lutar contra um inimigo**: luta em turnos com a arma mais forte do inventário principal, usando o dano e a defesa dos dois lados e a chance de crítico do jogador. A vida do jogador é atualizada no banco. Se ele vence, os drops são sorteados e guardados no inventário principal. Se perde, morre (`is_alive = false`) e não pode mais lutar. As regras estão em [`docs/mudancas.md`](docs/mudancas.md#m11-dano-dos-inimigos-e-combate).

As buscas aceitam o id (mostrado nas listagens) ou parte do nome, sem diferenciar maiúsculas e minúsculas (por exemplo, `38` ou `iron pick`).
