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
