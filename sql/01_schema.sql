-- Criação das tabelas do banco Terraria (segunda iteração).
-- Ver docs/iteracao2/der.md e docs/mudancas.md.

-- Permite executar o script novamente, recriando o banco do zero.
DROP TABLE IF EXISTS inventory_item, inventory, player,
                     recipe_ingredient, recipe, enemy_drop, item,
                     enemy_biome, enemy, ai, biome CASCADE;

CREATE TABLE biome (
    id_biome serial PRIMARY KEY,
    name     text NOT NULL UNIQUE
);

CREATE TABLE ai (
    id_ai    serial PRIMARY KEY,
    name     text NOT NULL UNIQUE,
    behavior text
);

CREATE TABLE enemy (
    id_enemy        serial PRIMARY KEY,
    id_ai           integer NOT NULL REFERENCES ai (id_ai),
    name            text NOT NULL UNIQUE,
    hp              bigint NOT NULL,
    defense         integer NOT NULL,
    damage          integer NOT NULL,
    move_speed      real,
    does_enrage     boolean NOT NULL DEFAULT false,
    does_despawn    boolean NOT NULL DEFAULT false,
    is_invulnerable boolean NOT NULL DEFAULT false,
    lore            text,
    CHECK (hp > 0),
    CHECK (defense >= 0),
    CHECK (damage >= 0),
    CHECK (move_speed >= 0)
);

-- Um inimigo pode habitar vários biomas (relação N:N).
CREATE TABLE enemy_biome (
    id_enemy integer REFERENCES enemy (id_enemy) ON DELETE CASCADE,
    id_biome integer REFERENCES biome (id_biome),
    PRIMARY KEY (id_enemy, id_biome)
);

CREATE TABLE item (
    id_item serial PRIMARY KEY,
    name    text NOT NULL UNIQUE,
    type    text NOT NULL,
    rarity  text NOT NULL,
    damage  integer,
    CHECK (type IN ('weapon', 'tool', 'armor', 'accessory', 'block',
                    'material', 'consumable', 'ammo', 'crafting_station')),
    CHECK (rarity IN ('Gray', 'White', 'Blue', 'Green', 'Orange', 'Light Red',
                      'Pink', 'Light Purple', 'Lime', 'Yellow', 'Cyan',
                      'Red', 'Purple')),
    CHECK (damage >= 0)
);

-- "drop" é palavra reservada do SQL, por isso enemy_drop.
CREATE TABLE enemy_drop (
    id_enemy     integer REFERENCES enemy (id_enemy) ON DELETE CASCADE,
    id_item      integer REFERENCES item (id_item),
    chance       numeric(7, 6) NOT NULL,
    min_quantity integer NOT NULL DEFAULT 1,
    max_quantity integer NOT NULL DEFAULT 1,
    PRIMARY KEY (id_enemy, id_item),
    CHECK (chance > 0 AND chance <= 1),
    CHECK (min_quantity >= 1),
    CHECK (min_quantity <= max_quantity)
);

-- id_station nulo significa receita feita à mão.
CREATE TABLE recipe (
    id_recipe       serial PRIMARY KEY,
    id_result       integer NOT NULL REFERENCES item (id_item) ON DELETE CASCADE,
    result_quantity integer NOT NULL DEFAULT 1,
    id_station      integer REFERENCES item (id_item),
    CHECK (result_quantity > 0)
);

CREATE TABLE recipe_ingredient (
    id_recipe     integer REFERENCES recipe (id_recipe) ON DELETE CASCADE,
    id_ingredient integer REFERENCES item (id_item),
    quantity      integer NOT NULL,
    PRIMARY KEY (id_recipe, id_ingredient),
    CHECK (quantity > 0)
);

CREATE TABLE player (
    id_player        serial PRIMARY KEY,
    name             text NOT NULL UNIQUE,
    hp               integer NOT NULL,
    max_hp           integer NOT NULL,
    mana             integer NOT NULL,
    max_mana         integer NOT NULL,
    class            text NOT NULL,
    move_speed       real NOT NULL DEFAULT 1,
    crit_chance      real NOT NULL DEFAULT 0.04,
    is_alive         boolean NOT NULL DEFAULT false,
    used_demon_heart boolean NOT NULL DEFAULT false,
    coins            integer NOT NULL DEFAULT 0,
    team             text NOT NULL DEFAULT 'none',
    general_stats    jsonb,
    CHECK (max_hp BETWEEN 100 AND 500),
    CHECK (hp BETWEEN 0 AND max_hp),
    CHECK (max_mana BETWEEN 20 AND 200),
    CHECK (mana BETWEEN 0 AND max_mana),
    CHECK (class IN ('melee', 'ranged', 'magic', 'summoner')),
    CHECK (move_speed > 0),
    CHECK (crit_chance BETWEEN 0 AND 1),
    CHECK (coins >= 0),
    CHECK (team IN ('none', 'red', 'green', 'blue', 'yellow', 'pink'))
);

CREATE TABLE inventory (
    id_inventory serial PRIMARY KEY,
    id_player    integer NOT NULL REFERENCES player (id_player) ON DELETE CASCADE,
    type         text NOT NULL,
    capacity     integer NOT NULL,
    UNIQUE (id_player, type),
    CHECK (type IN ('main', 'piggy_bank', 'safe', 'ammo', 'equipment')),
    CHECK (capacity > 0)
);

CREATE TABLE inventory_item (
    id_inventory integer REFERENCES inventory (id_inventory) ON DELETE CASCADE,
    slot         integer,
    id_item      integer NOT NULL REFERENCES item (id_item),
    quantity     integer NOT NULL DEFAULT 1,
    equipped     boolean NOT NULL DEFAULT false,
    PRIMARY KEY (id_inventory, slot),
    CHECK (slot >= 0),
    CHECK (quantity > 0)
);
