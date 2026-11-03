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
