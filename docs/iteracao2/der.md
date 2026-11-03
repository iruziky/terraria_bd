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
```
