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
