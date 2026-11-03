# Mudanças da primeira para a segunda iteração

Este documento lista o que mudou entre o diagrama UML do trabalho 1 ([`docs/iteracao1`](iteracao1/projeto_bd_terraria.md)) e o DER implementado no trabalho 2 ([`docs/iteracao2/der.md`](iteracao2/der.md)), com a justificativa de cada mudança.

## M1. Nomenclatura em `snake_case` e em inglês

**Antes:** nomes em `camelCase`, misturando português e inglês (`idJogador`, `nameCreature`, `movSpeed`, `quantidadeMin`).

**Depois:** todas as tabelas e colunas em `snake_case` e em inglês (`id_player`, `name`, `move_speed`, `min_quantity`).

**Por quê:** o PostgreSQL converte identificadores sem aspas para minúsculas, então `idJogador` viraria `idjogador`, que é difícil de ler. Padronizar o idioma evita misturas como `idCreature` numa tabela `Inimigo`.

| Iteração 1 | Iteração 2 |
|---|---|
| `Jogador` (`idJogador`, `nomeJogador`, `hp`, `maxHP`, `mana`, `maxMana`, `classe`, `movSpeed`, `critChance`, `isAlive`, `coinBag`, `team`) | `player` (`id_player`, `name`, `hp`, `max_hp`, `mana`, `max_mana`, `class`, `move_speed`, `crit_chance`, `is_alive`, `coins`, `team`) |
| `Inventario` (`idInventario`, `idJogador`, `tipo`, `capacidade`) | `inventory` (`id_inventory`, `id_player`, `type`, `capacity`) |
| `ItemInventario` (`idInventario`, `slot`, `idItem`, `quantidade`, `equipado`) | `inventory_item` (`id_inventory`, `slot`, `id_item`, `quantity`, `equipped`) |
| `Item` (`idItem`, `nomeItem`, `tipo`, `raridade`, `dano`) | `item` (`id_item`, `name`, `type`, `rarity`, `damage`) |
| `Bioma` (`idBioma`, `nomeBioma`) | `biome` (`id_biome`, `name`) |
| `AI` (`idAI`, `nome`, `padraoComportamento`) | `ai` (`id_ai`, `name`, `behavior`) |
| `Inimigo` (`idCreature`, `idAI`, `nameCreature`, `hp`, `armour`, `movSpeed`, `doEnrage`, `doDespawn`, `isInvulnerable`, `lore`) | `enemy` (`id_enemy`, `id_ai`, `name`, `hp`, `defense`, `move_speed`, `does_enrage`, `does_despawn`, `is_invulnerable`, `lore`) |
| `Receita` (`idReceita`, `idResultado`, `quantidadeResultado`) | `recipe` (`id_recipe`, `id_result`, `result_quantity`) |
| `IngredienteReceita` (`idReceita`, `idIngrediente`, `quantidade`) | `recipe_ingredient` (`id_recipe`, `id_ingredient`, `quantity`) |

## M2. Tabela `Drop` renomeada para `enemy_drop`

**Antes:** `Drop` (`idCreature`, `idItem`, `chance`, `quantidadeMin`, `quantidadeMax`).

**Depois:** `enemy_drop` (`id_enemy`, `id_item`, `chance`, `min_quantity`, `max_quantity`).

**Por quê:** `DROP` é palavra reservada do SQL (`DROP TABLE`). Usar esse nome exigiria aspas em todas as consultas.

## M3. ENUMs substituídos por `text` com `CHECK`

**Antes:** `ENUM` em `Jogador.classe`, `Inventario.tipo` e `Item.tipo`.

**Depois:** colunas `text` com `CHECK (coluna IN (...))`. A mesma técnica foi aplicada a `player.team` e `item.rarity`, que antes eram texto livre:

| Coluna | Valores permitidos |
|---|---|
| `player.class` | `melee`, `ranged`, `magic`, `summoner` |
| `player.team` | `none`, `red`, `green`, `blue`, `yellow`, `pink` |
| `inventory.type` | `main`, `piggy_bank`, `safe`, `ammo`, `equipment` |
| `item.type` | `weapon`, `tool`, `armor`, `accessory`, `block`, `material`, `consumable`, `ammo`, `crafting_station` |
| `item.rarity` | `Gray`, `White`, `Blue`, `Green`, `Orange`, `Light Red`, `Pink`, `Light Purple`, `Lime`, `Yellow`, `Cyan`, `Red`, `Purple` |

**Por quê:** restrições de domínio com `CHECK` foram o conteúdo visto em aula e são mais fáceis de alterar que um tipo `ENUM` (basta trocar a restrição). Os nomes de raridade seguem a [página de raridade da wiki](https://terraria.wiki.gg/wiki/Rarity).

## M4. Restrições explícitas

**Antes:** o diagrama só mostrava tipos, PKs e FKs.

**Depois:** cada tabela declara as restrições de domínio:

- `NOT NULL` em tudo que é obrigatório e `UNIQUE` nos nomes de jogador, item, bioma, IA e inimigo;
- `0 <= hp <= max_hp`, com `max_hp` entre 100 e 500 (vida inicial e vida máxima do jogo);
- `0 <= mana <= max_mana`, com `max_mana` entre 20 e 200;
- `crit_chance` entre 0 e 1, `move_speed > 0` e `coins >= 0`;
- `chance` do drop em `(0, 1]` e `1 <= min_quantity <= max_quantity`;
- quantidades, capacidades e vida dos inimigos positivas; `slot`, `defense` e `damage` não negativos.

**Por quê:** garante no próprio banco que dados impossíveis no jogo (vida negativa, chance de 150%) não sejam inseridos, em vez de depender da aplicação.

## M9. Um inventário de cada tipo por jogador

**Depois:** `UNIQUE (id_player, type)` em `inventory`.

**Por quê:** no jogo, cada jogador tem exatamente um inventário principal, um Piggy Bank, um cofre etc. Sem essa restrição, seria possível criar dois inventários principais para o mesmo jogador.

## M5. Inimigo ↔ Bioma passa a ser N:N

**Antes:** `Inimigo.idBioma` (FK), ou seja, cada inimigo pertencia a um único bioma (`1 : 0..*`).

**Depois:** nova tabela associativa `enemy_biome (id_enemy, id_biome)` e `enemy` sem `id_biome`.

**Por quê:** ao popular o banco com dados da wiki, vimos que vários inimigos aparecem em mais de um bioma. O Blue Slime aparece na Forest e no Underground, e o Giant Worm no Underground e no Cavern. O modelo 1:N obrigaria a escolher um bioma só ou a duplicar o inimigo.

## M6. Estação de crafting passa a ser um item

**Antes:** `Receita.estacaoCraft VARCHAR`.

**Depois:** `recipe.id_station`, FK para `item`, que pode ser nulo (receita feita à mão).

**Por quê:** as estações (Work Bench, Furnace, Iron Anvil) são itens do jogo e também têm receitas. Com texto livre, `'Work Bench'` e `'workbench'` seriam estações diferentes e não daria para consultar "o que preciso para construir a estação desta receita". Com a FK, a estação é validada e pode ser ligada às outras tabelas. Até um item comum pode ser estação: a Bottle colocada no mundo (Placed Bottle) é a estação das poções.

## M7. Remoção de `Jogador.hookSlot`

**Antes:** `hookSlot VARCHAR` no jogador.

**Depois:** o gancho é um item (por exemplo, Grappling Hook) guardado no inventário do tipo `equipment`, com `equipped = true`.

**Por quê:** era redundância. O equipamento já é modelado por `inventory` e `inventory_item`. A capacidade do inventário `equipment` nos dados é 9: 3 de armadura + 5 de acessório + 1 de gancho. Com o Demon Heart, sobe para 10.

## A10. `corruptedHeart` renomeado para `used_demon_heart`

**Antes:** `corruptedHeart BOOLEAN`.

**Depois:** `used_demon_heart boolean`.

**Por quê:** na wiki não existe nenhum item ou estado do jogador chamado "Corrupted Heart" (os "corações" da Corruption/Crimson são objetos do mundo, não do jogador). O equivalente mais próximo é o [Demon Heart](https://terraria.wiki.gg/wiki/Demon_Heart), um consumível que "permanentemente concede ao jogador um slot de acessório extra" e só pode ser usado uma vez por jogador. Por isso, um booleano no jogador faz sentido.

## M8. `statusGerais JSON` → `general_stats jsonb`

**Antes:** `statusGerais JSON`, sem conteúdo definido.

**Depois:** `general_stats jsonb` com as chaves `defense`, `life_regen` e `luck`.

**Por quê:** `jsonb` é a forma recomendada pelo PostgreSQL de guardar JSON (binária, indexável e com operadores como `->>`). As chaves foram fixadas para que o conteúdo do campo seja conhecido e possa ser usado nas consultas.

## M10. Ações nas chaves estrangeiras

**Antes:** o diagrama não definia o que acontece ao apagar uma linha referenciada.

**Depois:**

| FK | Ação | Motivo |
|---|---|---|
| `inventory.id_player` | `ON DELETE CASCADE` | Apagar um jogador apaga seus inventários. |
| `inventory_item.id_inventory` | `ON DELETE CASCADE` | Apagar um inventário apaga seus slots. |
| `enemy_biome.id_enemy`, `enemy_drop.id_enemy` | `ON DELETE CASCADE` | Os biomas e drops de um inimigo só existem por causa dele. |
| `recipe.id_result`, `recipe_ingredient.id_recipe` | `ON DELETE CASCADE` | As receitas de um item e os ingredientes de uma receita pertencem a eles. |
| `inventory_item.id_item`, `enemy_drop.id_item`, `recipe_ingredient.id_ingredient`, `recipe.id_station`, `enemy.id_ai`, `enemy_biome.id_biome` | `RESTRICT` (padrão) | Não se pode apagar um item, IA ou bioma que ainda está em uso. |
