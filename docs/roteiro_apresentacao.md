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

## 4. Exemplos de utilização

### Consultas (`sql/03_consultas.sql`)

Rodar o arquivo inteiro ou mostrar algumas consultas:

- **3:** inventário do Iruziky (junção de 4 tabelas);
- **7:** formas de obter Gel, Hook, Torch e Grappling Hook (`UNION`);
- **11 e 11b:** divisão. Iruziky e Heitor têm todos os ingredientes da Iron Pickaxe, mas só o Iruziky tem a quantidade necessária;
- **16:** restrições em ação (cada comando falha com a mensagem da restrição).

### Aplicação (`app/main.py`)

Sequência sugerida:

1. `1` listar jogadores: o Davi está morto, com 0 de vida.
2. `5` receita de `iron pickaxe`: 10 Iron Bar + 3 Wood na Iron Anvil.
3. `6` fabricar com `heitor` e `iron pickaxe`: falha e mostra que faltam Iron Bars (tem 4 de 10).
4. `6` fabricar com `iruziky` e `iron pickaxe`: funciona.
5. `2` inventário do `iruziky`: a picareta apareceu num slot novo, e Iron Bar e Wood diminuíram.
6. `4` como obter `hook`: drop do Skeleton e da Piranha.
7. `7` derrotar `demon eye` com o `heitor` algumas vezes: às vezes dropa Lens (33,33%).
8. `6` fabricar `lesser healing potion` com o `heitor` (funciona) e com o `iruziky` (falta Bottle).
