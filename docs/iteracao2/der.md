# DER — Segunda iteração

Diagrama em notação pé-de-galinha (crow's foot). As tabelas e colunas estão exatamente como em `sql/01_schema.sql`. As mudanças em relação à primeira iteração estão em [`docs/mudancas.md`](../mudancas.md).

```mermaid
erDiagram
    biome {
        serial id_biome PK
        text name UK
    }
    ai {
        serial id_ai PK
        text name UK
        text behavior
    }
    enemy {
        serial id_enemy PK
        int id_ai FK
        text name UK
        bigint hp
        int defense
        int damage
        real move_speed
        boolean does_enrage
        boolean does_despawn
        boolean is_invulnerable
        text lore
    }
    enemy_biome {
        int id_enemy PK,FK
        int id_biome PK,FK
    }
    ai ||--o{ enemy : "segue"
    enemy ||--|{ enemy_biome : "habita"
    biome ||--o{ enemy_biome : "abriga"
    item {
        serial id_item PK
        text name UK
        text type
        text rarity
        int damage
    }
    enemy_drop {
        int id_enemy PK,FK
        int id_item PK,FK
        numeric chance
        int min_quantity
        int max_quantity
    }
    enemy ||--o{ enemy_drop : "origina"
    item ||--o{ enemy_drop : "e obtido em"
    recipe {
        serial id_recipe PK
        int id_result FK
        int result_quantity
        int id_station FK
    }
    recipe_ingredient {
        int id_recipe PK,FK
        int id_ingredient PK,FK
        int quantity
    }
    item ||--o{ recipe : "produz"
    item |o--o{ recipe : "e estacao de"
    recipe ||--|{ recipe_ingredient : "exige"
    item ||--o{ recipe_ingredient : "participa"
    player {
        serial id_player PK
        text name UK
        int hp
        int max_hp
        int mana
        int max_mana
        text class
        real move_speed
        real crit_chance
        boolean is_alive
        boolean used_demon_heart
        int coins
        text team
        jsonb general_stats
    }
    inventory {
        serial id_inventory PK
        int id_player FK
        text type
        int capacity
    }
    inventory_item {
        int id_inventory PK,FK
        int slot PK
        int id_item FK
        int quantity
        boolean equipped
    }
    player ||--|{ inventory : "possui"
    inventory ||--o{ inventory_item : "contem"
    item ||--o{ inventory_item : "ocupa"
```

## Cardinalidades

| Relacionamento | Cardinalidade | Significado |
|---|---|---|
| player — inventory | `1 : 1..*` | Um jogador possui um ou mais inventários (no máximo um de cada tipo). |
| inventory — inventory_item | `1 : 0..*` | Um inventário pode ter vários slots ocupados. |
| item — inventory_item | `1 : 0..*` | Um item pode aparecer em vários slots e inventários. |
| enemy — biome (via enemy_biome) | `N : M` | Um inimigo habita um ou mais biomas; um bioma abriga zero ou mais inimigos. |
| ai — enemy | `1 : 0..*` | Um padrão de IA pode ser usado por vários inimigos. |
| enemy — enemy_drop | `1 : 0..*` | Um inimigo pode ter vários drops. |
| item — enemy_drop | `1 : 0..*` | Um item pode ser dropado por vários inimigos. |
| item — recipe (resultado) | `1 : 0..*` | Um item pode ter várias receitas alternativas. |
| item — recipe (estação) | `0..1 : 0..*` | Uma receita exige no máximo uma estação, que também é um item; sem estação, é feita à mão. |
| recipe — recipe_ingredient | `1 : 1..*` | Uma receita exige pelo menos um ingrediente. |
| item — recipe_ingredient | `1 : 0..*` | Um item pode ser ingrediente de várias receitas. |
