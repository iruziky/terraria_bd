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

-- Materiais, blocos e consumíveis.
INSERT INTO item (id_item, name, type, rarity, damage) VALUES
    (1, 'Wood', 'block', 'White', NULL),
    (2, 'Stone Block', 'block', 'White', NULL),
    (3, 'Sand Block', 'block', 'White', NULL),
    (4, 'Glass', 'block', 'White', NULL),
    (5, 'Gel', 'material', 'White', NULL),
    (6, 'Torch', 'material', 'White', NULL),
    (7, 'Mushroom', 'consumable', 'White', NULL),
    (8, 'Bottle', 'material', 'White', NULL),
    (9, 'Lesser Healing Potion', 'consumable', 'White', NULL),
    (10, 'Copper Ore', 'material', 'White', NULL),
    (11, 'Copper Bar', 'material', 'White', NULL),
    (12, 'Iron Ore', 'material', 'White', NULL),
    (13, 'Iron Bar', 'material', 'White', NULL),
    (14, 'Demonite Ore', 'material', 'Blue', NULL),
    (15, 'Demonite Bar', 'material', 'Blue', NULL),
    (16, 'Chain', 'material', 'White', NULL),
    (17, 'Hook', 'material', 'White', NULL),
    (18, 'Lens', 'material', 'White', NULL),
    (19, 'Black Lens', 'material', 'White', NULL),
    (20, 'Rotten Chunk', 'material', 'White', NULL),
    (21, 'Vertebra', 'material', 'White', NULL),
    (22, 'Antlion Mandible', 'material', 'White', NULL),
    (23, 'Fallen Star', 'material', 'Blue', NULL),
    (24, 'Life Crystal', 'consumable', 'Green', NULL),
    (25, 'Mana Crystal', 'consumable', 'Green', NULL);

-- Estações de crafting, armas, ferramentas, munições e equipamentos.
INSERT INTO item (id_item, name, type, rarity, damage) VALUES
    (26, 'Work Bench', 'crafting_station', 'White', NULL),
    (27, 'Furnace', 'crafting_station', 'White', NULL),
    (28, 'Iron Anvil', 'crafting_station', 'White', NULL),
    (29, 'Wooden Sword', 'weapon', 'White', 7),
    (30, 'Wooden Bow', 'weapon', 'White', 4),
    (31, 'Copper Shortsword', 'weapon', 'White', 5),
    (32, 'Iron Broadsword', 'weapon', 'White', 12),
    (33, 'Light''s Bane', 'weapon', 'Blue', 16),
    (34, 'Zombie Arm', 'weapon', 'White', 15),
    (35, 'Chain Knife', 'weapon', 'Blue', 12),
    (36, 'Bone Sword', 'weapon', 'Orange', 19),
    (37, 'Copper Pickaxe', 'tool', 'White', 4),
    (38, 'Iron Pickaxe', 'tool', 'White', 5),
    (39, 'Grappling Hook', 'tool', 'Blue', NULL),
    (40, 'Wooden Arrow', 'ammo', 'White', 5),
    (41, 'Flaming Arrow', 'ammo', 'White', 7),
    (42, 'Musket Ball', 'ammo', 'White', 7),
    (43, 'Copper Helmet', 'armor', 'White', NULL),
    (44, 'Copper Chainmail', 'armor', 'White', NULL),
    (45, 'Copper Greaves', 'armor', 'White', NULL),
    (46, 'Goggles', 'armor', 'White', NULL),
    (47, 'Sunglasses', 'armor', 'Green', NULL),
    (48, 'Mining Helmet', 'armor', 'Blue', NULL),
    (49, 'Shackle', 'accessory', 'Blue', NULL),
    (50, 'Hermes Boots', 'accessory', 'Blue', NULL),
    (51, 'Depth Meter', 'accessory', 'Blue', NULL),
    (52, 'Compass', 'accessory', 'Blue', NULL),
    (53, 'Magma Stone', 'accessory', 'Orange', NULL);

-- Vida, defesa e dano de contato no modo Classic; lore é a entrada do Bestiário.
-- Antlion: o dano é o do ataque de areia, porque ele não se move.
-- move_speed fica nulo porque a wiki não informa a velocidade dos inimigos.
-- Giant Worm: defesa e dano da cabeça (o corpo tem defesa 4 e a cauda 6).
INSERT INTO enemy (id_enemy, id_ai, name, hp, defense, damage, does_despawn, lore) VALUES
    (1, 1, 'Green Slime', 14, 0, 6, true, 'A simple, gelatinous creature that swallows anything and everything whole! It takes a long time to digest anything.'),
    (2, 1, 'Blue Slime', 25, 2, 7, true, 'A simple, gelatinous creature that swallows anything and everything whole! It takes a long time to digest anything.'),
    (3, 1, 'Jungle Slime', 60, 6, 18, true, 'A simple, gelatinous creature that swallows anything and everything whole! It takes a long time to digest anything.'),
    (4, 1, 'Ice Slime', 30, 4, 8, true, 'Slimes that spent too long in arctic temperatures may begin to partially freeze, developing a shifting layer of ice on their surface.'),
    (5, 1, 'Lava Slime', 50, 10, 15, true, 'Due to the heat of the underworld, these slimes have taken on the properties of lava. Slaying them is difficult and dangerous.'),
    (6, 2, 'Demon Eye', 60, 2, 18, true, 'That suspicious feeling of being watched may very well come true in the dark of night, when Cthulhu''s minions roam the skies.'),
    (7, 3, 'Zombie', 45, 6, 14, true, 'Leaving doors open may be an invitation for shambling brain-eaters to enter the home, and nobody likes that.'),
    (8, 3, 'Skeleton', 60, 8, 20, true, 'Who needs muscles, skin, or even eyeballs? Skeletons get by with just the bones on their back, just as deadly as more fleshy foes.'),
    (9, 14, 'Cave Bat', 16, 2, 13, true, 'They are small, hard to see, and swiftly flap about in unpredictable ways. They often carry diseases, such as rabies.'),
    (10, 14, 'Hellbat', 46, 8, 35, true, 'What''s worse than a rabid, fast-flying, and annoying flying rodent? One that is on fire, of course!'),
    (11, 5, 'Eater of Souls', 40, 8, 22, true, 'Birthed from the Corruption as a being of pure malice, its sole instincts are to pursue, punish, and kill.'),
    (12, 5, 'Crimera', 40, 8, 22, true, 'The most common horror to be born from the Crimson, it seeks to consume pure things with unrelenting hunger.'),
    (13, 6, 'Giant Worm', 30, 0, 8, true, 'These itty bitty diggy dawgs dig through the earth and take focused spelunkers by surprise, causing unwanted distress.'),
    (14, 16, 'Piranha', 30, 2, 25, true, 'Just one of these sharp-toothed fish can easily end a life. Luckily, they tend to swarm their victims in large groups! Life is grand.'),
    (15, 19, 'Antlion', 45, 6, 10, true, 'When antlions are nesting, they hide in the surface. To defend their eggs, they projectile vomit hard globs of sand at trespassers.');

INSERT INTO enemy_biome (id_enemy, id_biome) VALUES
    (1, 1),
    (2, 1), (2, 7),
    (3, 4),
    (4, 3),
    (5, 9),
    (6, 1),
    (7, 1),
    (8, 8),
    (9, 8),
    (10, 9),
    (11, 5),
    (12, 6),
    (13, 7), (13, 8),
    (14, 4), (14, 8),
    (15, 2);

-- Chance como fração (0.333333 = 33,33%). Quando a wiki não mostra
-- quantidade, o drop é de 1 unidade. Moedas não são registradas como drop.
INSERT INTO enemy_drop (id_enemy, id_item, chance, min_quantity, max_quantity) VALUES
    (1, 5, 1, 1, 2),
    (2, 5, 1, 1, 2),
    (3, 5, 1, 1, 2),
    (4, 5, 1, 1, 2),
    (6, 18, 0.333333, 1, 1),
    (6, 19, 0.01, 1, 1),
    (7, 49, 0.02, 1, 1),
    (7, 34, 0.004, 1, 1),
    (8, 17, 0.04, 1, 1),
    (8, 36, 0.005, 1, 1),
    (9, 35, 0.004, 1, 1),
    (9, 51, 0.01, 1, 1),
    (10, 53, 0.0067, 1, 1),
    (11, 20, 0.333333, 1, 1),
    (12, 21, 0.333333, 1, 1),
    (14, 17, 0.033, 1, 1),
    (14, 52, 0.0133, 1, 1),
    (15, 22, 0.333, 1, 2);

-- Estações: 26 = Work Bench, 27 = Furnace, 28 = Iron Anvil,
-- 8 = Bottle (colocada no mundo, funciona como Placed Bottle). NULL = à mão.
INSERT INTO recipe (id_recipe, id_result, result_quantity, id_station) VALUES
    (1, 26, 1, NULL),
    (2, 6, 3, NULL),
    (3, 27, 1, 26),
    (4, 11, 1, 27),
    (5, 13, 1, 27),
    (6, 28, 1, 26),
    (7, 4, 1, 27),
    (8, 8, 2, 27),
    (9, 9, 2, 8),
    (10, 15, 1, 27);

INSERT INTO recipe_ingredient (id_recipe, id_ingredient, quantity) VALUES
    (1, 1, 10),
    (2, 5, 1), (2, 1, 1),
    (3, 2, 20), (3, 1, 4), (3, 6, 3),
    (4, 10, 3),
    (5, 12, 3),
    (6, 13, 5),
    (7, 3, 2),
    (8, 4, 1),
    (9, 7, 1), (9, 5, 2), (9, 8, 2),
    (10, 14, 3);

INSERT INTO recipe (id_recipe, id_result, result_quantity, id_station) VALUES
    (11, 29, 1, 26),
    (12, 30, 1, 26),
    (13, 40, 25, 26),
    (14, 41, 10, NULL),
    (15, 31, 1, 28),
    (16, 32, 1, 28),
    (17, 33, 1, 28),
    (18, 37, 1, 28),
    (19, 38, 1, 28),
    (20, 16, 15, 28),
    (21, 39, 1, 28);

INSERT INTO recipe_ingredient (id_recipe, id_ingredient, quantity) VALUES
    (11, 1, 7),
    (12, 1, 10),
    (13, 1, 1), (13, 2, 1),
    (14, 40, 10), (14, 6, 1),
    (15, 11, 5),
    (16, 13, 8),
    (17, 15, 10),
    (18, 11, 8), (18, 1, 4),
    (19, 13, 10), (19, 1, 3),
    (20, 13, 1),
    (21, 16, 3), (21, 17, 1);

INSERT INTO recipe (id_recipe, id_result, result_quantity, id_station) VALUES
    (22, 43, 1, 28),
    (23, 44, 1, 28),
    (24, 45, 1, 28),
    (25, 46, 1, 26),
    (26, 47, 1, 26);

INSERT INTO recipe_ingredient (id_recipe, id_ingredient, quantity) VALUES
    (22, 11, 12),
    (23, 11, 20),
    (24, 11, 16),
    (25, 18, 2),
    (26, 19, 2);

-- Jogadores fictícios com os nomes do grupo. coins em moedas de cobre.
INSERT INTO player (id_player, name, hp, max_hp, mana, max_mana, class, move_speed,
                    crit_chance, is_alive, used_demon_heart, coins, team, general_stats) VALUES
    (1, 'Iruziky', 200, 200, 40, 40, 'melee', 1, 0.04, true, false, 54321, 'red',
        '{"defense": 5, "life_regen": 1, "luck": 0}'),
    (2, 'Heitor', 140, 160, 20, 20, 'ranged', 1, 0.04, true, false, 12050, 'blue',
        '{"defense": 1, "life_regen": 0, "luck": 0}'),
    (3, 'Davi', 0, 300, 100, 120, 'magic', 1, 0.04, false, true, 250000, 'none',
        '{"defense": 2, "life_regen": 0, "luck": 0.1}');

-- Capacidades do jogo: main 50 (40 + 10 da hotbar), piggy_bank e safe 40,
-- ammo 4, equipment 9 (3 armaduras + 5 acessórios + 1 gancho; +1 com Demon Heart).
INSERT INTO inventory (id_inventory, id_player, type, capacity) VALUES
    (1, 1, 'main', 50), (2, 1, 'piggy_bank', 40), (3, 1, 'safe', 40),
    (4, 1, 'ammo', 4), (5, 1, 'equipment', 9),
    (6, 2, 'main', 50), (7, 2, 'piggy_bank', 40), (8, 2, 'safe', 40),
    (9, 2, 'ammo', 4), (10, 2, 'equipment', 9),
    (11, 3, 'main', 50), (12, 3, 'piggy_bank', 40), (13, 3, 'safe', 40),
    (14, 3, 'ammo', 4), (15, 3, 'equipment', 10);

-- Iruziky consegue fabricar a Iron Pickaxe (10 Iron Bar + 3 Wood) e Heitor não.
-- Heitor consegue fabricar a Lesser Healing Potion e Iruziky não (falta Bottle).
INSERT INTO inventory_item (id_inventory, slot, id_item, quantity, equipped) VALUES
    (1, 0, 32, 1, false), (1, 1, 37, 1, false), (1, 2, 6, 45, false),
    (1, 3, 1, 30, false), (1, 4, 13, 12, false), (1, 5, 5, 14, false),
    (1, 6, 9, 5, false), (1, 7, 2, 120, false), (1, 8, 18, 3, false),
    (1, 9, 7, 2, false),
    (2, 0, 24, 1, false), (2, 1, 23, 4, false),
    (3, 0, 10, 40, false),
    (5, 0, 43, 1, true), (5, 1, 44, 1, true), (5, 2, 45, 1, true),
    (5, 3, 50, 1, true), (5, 4, 49, 1, true),

    (6, 0, 30, 1, false), (6, 1, 37, 1, false), (6, 2, 1, 50, false),
    (6, 3, 13, 4, false), (6, 4, 6, 20, false), (6, 5, 5, 30, false),
    (6, 6, 8, 4, false), (6, 7, 7, 3, false), (6, 8, 19, 1, false),
    (6, 9, 20, 6, false),
    (7, 0, 4, 10, false),
    (9, 0, 40, 250, false), (9, 1, 41, 80, false), (9, 2, 42, 100, false),
    (10, 0, 46, 1, true), (10, 1, 52, 1, true), (10, 2, 39, 1, true),

    (11, 0, 29, 1, false), (11, 1, 14, 15, false), (11, 2, 3, 60, false),
    (11, 3, 18, 1, false), (11, 4, 21, 8, false), (11, 5, 25, 2, false),
    (11, 6, 23, 10, false),
    (13, 0, 15, 4, false), (13, 1, 12, 30, false),
    (15, 0, 48, 1, true), (15, 1, 51, 1, true), (15, 2, 53, 1, true),
    (15, 3, 47, 1, false);

-- Como os ids foram inseridos manualmente, as sequências dos serial
-- precisam continuar a partir do maior id existente.
SELECT setval('biome_id_biome_seq', (SELECT max(id_biome) FROM biome));
SELECT setval('ai_id_ai_seq', (SELECT max(id_ai) FROM ai));
SELECT setval('item_id_item_seq', (SELECT max(id_item) FROM item));
SELECT setval('enemy_id_enemy_seq', (SELECT max(id_enemy) FROM enemy));
SELECT setval('recipe_id_recipe_seq', (SELECT max(id_recipe) FROM recipe));
SELECT setval('player_id_player_seq', (SELECT max(id_player) FROM player));
SELECT setval('inventory_id_inventory_seq', (SELECT max(id_inventory) FROM inventory));
