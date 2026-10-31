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
