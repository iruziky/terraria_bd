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

## 3. Mudanças da primeira para a segunda iteração

Mostrar [`mudancas.md`](mudancas.md). Pontos principais:

1. **Inimigo ↔ Bioma virou N:N.** Ao popular com dados reais, vimos que o Blue Slime aparece na Forest e no Underground. É a mudança de modelo mais importante.
2. **Estação de crafting virou FK para item.** A Work Bench é um item com receita própria, e a Bottle é a estação das poções.
3. **`Drop` virou `enemy_drop`**, porque `DROP` é palavra reservada.
4. **ENUMs viraram `CHECK`**, e foram adicionadas restrições de domínio (vida entre 0 e o máximo, chance entre 0 e 1, um inventário de cada tipo por jogador).
5. **`hookSlot` saiu** (o gancho é um item no inventário de equipamento) e **`corruptedHeart` virou `used_demon_heart`**, o item equivalente encontrado na wiki.
6. Nomes em `snake_case` e em inglês, `jsonb` e ações `CASCADE`/`RESTRICT` nas FKs.
