-- Criação das tabelas do banco Terraria (segunda iteração).
-- Ver docs/iteracao2/der.md e docs/mudancas.md.

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
    move_speed      real,
    does_enrage     boolean NOT NULL DEFAULT false,
    does_despawn    boolean NOT NULL DEFAULT false,
    is_invulnerable boolean NOT NULL DEFAULT false,
    lore            text
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
    damage  integer
);

-- "drop" é palavra reservada do SQL, por isso enemy_drop.
CREATE TABLE enemy_drop (
    id_enemy     integer REFERENCES enemy (id_enemy) ON DELETE CASCADE,
    id_item      integer REFERENCES item (id_item),
    chance       numeric(7, 6) NOT NULL,
    min_quantity integer NOT NULL DEFAULT 1,
    max_quantity integer NOT NULL DEFAULT 1,
    PRIMARY KEY (id_enemy, id_item)
);
