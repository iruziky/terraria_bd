-- População do banco Terraria.
-- Dados do jogo (biomas, IAs, inimigos, itens, drops e receitas) retirados de
-- https://terraria.wiki.gg (versão PC, modo Classic, pré-Hardmode).
-- Jogadores e inventários são fictícios.

INSERT INTO biome (id_biome, name) VALUES
    (1, 'Forest'),
    (2, 'Desert'),
    (3, 'Snow'),
    (4, 'Jungle'),
    (5, 'Corruption'),
    (6, 'Crimson'),
    (7, 'Underground'),
    (8, 'Cavern'),
    (9, 'Underworld'),
    (10, 'Ocean');

-- id_ai igual ao ID do estilo de IA na wiki (https://terraria.wiki.gg/wiki/AI).
INSERT INTO ai (id_ai, name, behavior) VALUES
    (1, 'Slime AI', 'Hops in one direction, slides on slopes, floats in water, follows player if damaged or during nighttime.'),
    (2, 'Demon Eye AI', 'Flies, follows player, bounces off walls in an arc.'),
    (3, 'Fighter AI', 'Will walk, jump over holes, follow player.'),
    (5, 'Flying AI', 'Flies, looks at player, follows player.'),
    (6, 'Worm AI', 'Burrows in ground (and/or air), passes through blocks, follows player.'),
    (14, 'Bat AI', 'Spasmodically flies towards player.'),
    (16, 'Swimming AI', 'Swims back and forth and moves towards the player if they are in water.'),
    (19, 'Antlion AI', 'Looks at player, climbs overlapping blocks, shoots falling sand at nearby players.');
