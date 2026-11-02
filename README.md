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
