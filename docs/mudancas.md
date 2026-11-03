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
