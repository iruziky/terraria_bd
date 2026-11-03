# Roteiro da apresentação

Antes de começar: `docker compose down -v && docker compose up -d` para ter o banco limpo.

## 1. Minimundo

- Parte do universo do Terraria: jogadores, inventários, itens, inimigos, biomas, IAs, drops e receitas.
- Perguntas que o banco responde: o que um jogador tem, quais inimigos vivem num bioma, quem dropa um item, o que é preciso para fabricar algo e se um jogador consegue fabricar.
- Dados do jogo retirados da Terraria Wiki (versão PC, modo Classic, pré-Hardmode); jogadores fictícios.

## 2. DER

Mostrar [`iteracao2/der.md`](iteracao2/der.md) no GitHub.

- Entidades principais: `player`, `item`, `enemy` e `biome`.
- Entidades de apoio: `inventory`, `ai` e `recipe`.
- Associativas (resolvem N:N e guardam dados da relação): `inventory_item` (slot e quantidade), `enemy_drop` (chance e quantidades), `recipe_ingredient` (quantidade) e `enemy_biome`.
- Destacar `recipe`, que referencia `item` duas vezes: como resultado e como estação.
