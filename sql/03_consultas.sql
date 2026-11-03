-- Exemplos de utilização do banco Terraria.
-- Executar com: psql -h localhost -p 5433 -U postgres -d terraria -f sql/03_consultas.sql
-- As consultas que alteram dados ficam dentro de BEGIN ... ROLLBACK,
-- então o script pode ser executado várias vezes sem mudar o banco.

-- 1. Seleção: armas com dano maior que 10.
-- σ_{type='weapon' ∧ damage>10}(item)
SELECT * FROM item WHERE type = 'weapon' AND damage > 10;

-- 2. Projeção e renomeação: status resumido dos jogadores.
-- π_{name, hp, max_hp, defense}(player)
SELECT name AS jogador,
       hp || '/' || max_hp AS vida,
       mana || '/' || max_mana AS mana,
       general_stats ->> 'defense' AS defesa
FROM player;

-- 3. Junção de quatro tabelas: inventário completo do Iruziky.
SELECT inventory.type AS inventario, inventory_item.slot, item.name AS item,
       inventory_item.quantity AS quantidade, inventory_item.equipped AS equipado
FROM player
INNER JOIN inventory ON inventory.id_player = player.id_player
INNER JOIN inventory_item ON inventory_item.id_inventory = inventory.id_inventory
INNER JOIN item ON item.id_item = inventory_item.id_item
WHERE player.name = 'Iruziky'
ORDER BY inventory.type, inventory_item.slot;

-- 4. Inimigos que habitam o Cavern (passando pela tabela associativa enemy_biome).
SELECT enemy.name AS inimigo, enemy.hp AS vida, enemy.defense AS defesa, ai.name AS ia
FROM biome
INNER JOIN enemy_biome ON enemy_biome.id_biome = biome.id_biome
INNER JOIN enemy ON enemy.id_enemy = enemy_biome.id_enemy
INNER JOIN ai ON ai.id_ai = enemy.id_ai
WHERE biome.name = 'Cavern';

-- 5. Quais inimigos dropam o Hook e com que chance.
SELECT enemy.name AS inimigo,
       round(enemy_drop.chance * 100, 2) || '%' AS chance,
       enemy_drop.min_quantity || '-' || enemy_drop.max_quantity AS quantidade
FROM enemy_drop
INNER JOIN enemy ON enemy.id_enemy = enemy_drop.id_enemy
INNER JOIN item ON item.id_item = enemy_drop.id_item
WHERE item.name = 'Hook';

-- 6. Receita da Iron Pickaxe: ingredientes e estação.
-- A tabela item aparece três vezes (resultado, ingrediente e estação).
SELECT resultado.name AS resultado, recipe.result_quantity AS produz,
       ingrediente.name AS ingrediente, recipe_ingredient.quantity AS quantidade,
       coalesce(estacao.name, 'à mão') AS estacao
FROM recipe
INNER JOIN item AS resultado ON resultado.id_item = recipe.id_result
INNER JOIN recipe_ingredient ON recipe_ingredient.id_recipe = recipe.id_recipe
INNER JOIN item AS ingrediente ON ingrediente.id_item = recipe_ingredient.id_ingredient
LEFT JOIN item AS estacao ON estacao.id_item = recipe.id_station
WHERE resultado.name = 'Iron Pickaxe';

-- 7. União: todas as formas de obter alguns itens (drop ∪ receita).
SELECT item.name AS item, 'drop de ' || enemy.name AS origem
FROM enemy_drop
INNER JOIN item ON item.id_item = enemy_drop.id_item
INNER JOIN enemy ON enemy.id_enemy = enemy_drop.id_enemy
WHERE item.name IN ('Gel', 'Hook', 'Torch', 'Grappling Hook')
UNION
SELECT item.name, coalesce('receita em ' || estacao.name, 'receita à mão')
FROM recipe
INNER JOIN item ON item.id_item = recipe.id_result
LEFT JOIN item AS estacao ON estacao.id_item = recipe.id_station
WHERE item.name IN ('Gel', 'Hook', 'Torch', 'Grappling Hook')
ORDER BY item;

-- 8. Interseção: itens que são dropados por inimigos E usados como ingrediente.
SELECT item.name FROM item
INNER JOIN enemy_drop ON enemy_drop.id_item = item.id_item
INTERSECT
SELECT item.name FROM item
INNER JOIN recipe_ingredient ON recipe_ingredient.id_ingredient = item.id_item;

-- 9. Subtração: itens que não estão no inventário de nenhum jogador.
SELECT name FROM item
EXCEPT
SELECT item.name FROM item
INNER JOIN inventory_item ON inventory_item.id_item = item.id_item
ORDER BY name;

-- 9b. Subtração: inimigos que não dropam nenhum item (só moedas).
SELECT name FROM enemy
EXCEPT
SELECT enemy.name FROM enemy
INNER JOIN enemy_drop ON enemy_drop.id_enemy = enemy.id_enemy;

-- 10. Produto cartesiano: todas as combinações jogador × inventário,
-- filtradas para manter só os pares relacionados. O resultado é o mesmo
-- de um INNER JOIN com a condição no ON.
CREATE TEMP TABLE produto AS
    SELECT player.id_player, player.name, inventory.id_player AS dono, inventory.type
    FROM player
    CROSS JOIN inventory;

SELECT count(*) AS combinacoes FROM produto;
SELECT name, type FROM produto WHERE id_player = dono ORDER BY name, type;

SELECT player.name, inventory.type
FROM player
INNER JOIN inventory ON inventory.id_player = player.id_player
ORDER BY player.name, inventory.type;

-- 11. Divisão: jogadores que possuem TODOS os ingredientes da Iron Pickaxe
-- no inventário principal, sem olhar a quantidade.
-- posse(jogador, item) ÷ ingredientes(item)
CREATE TEMP TABLE ingredientes AS
    SELECT recipe_ingredient.id_ingredient AS id_item, recipe_ingredient.quantity
    FROM recipe
    INNER JOIN recipe_ingredient ON recipe_ingredient.id_recipe = recipe.id_recipe
    INNER JOIN item ON item.id_item = recipe.id_result
    WHERE item.name = 'Iron Pickaxe';

CREATE TEMP TABLE posse AS
    SELECT inventory.id_player, inventory_item.id_item, sum(inventory_item.quantity) AS quantity
    FROM inventory
    INNER JOIN inventory_item ON inventory_item.id_inventory = inventory.id_inventory
    WHERE inventory.type = 'main'
    GROUP BY inventory.id_player, inventory_item.id_item;

SELECT player.name
FROM player
WHERE NOT EXISTS (
    SELECT id_item FROM ingredientes
    EXCEPT
    SELECT id_item FROM posse WHERE posse.id_player = player.id_player
);

-- 11b. A mesma divisão, agora exigindo a quantidade necessária de cada ingrediente.
SELECT player.name
FROM player
WHERE NOT EXISTS (
    SELECT id_item FROM ingredientes
    EXCEPT
    SELECT posse.id_item FROM posse
    INNER JOIN ingredientes ON ingredientes.id_item = posse.id_item
    WHERE posse.id_player = player.id_player AND posse.quantity >= ingredientes.quantity
);

-- 12. Tabela temporária: resumo de cada jogador.
CREATE TEMP TABLE resumo_jogador AS
    SELECT player.name, count(inventory_item.slot) AS slots_ocupados,
           coalesce(sum(inventory_item.quantity), 0) AS total_itens
    FROM player
    INNER JOIN inventory ON inventory.id_player = player.id_player
    LEFT JOIN inventory_item ON inventory_item.id_inventory = inventory.id_inventory
    GROUP BY player.name;

SELECT * FROM resumo_jogador ORDER BY total_itens DESC;

-- 13. Contagens: inimigos por bioma (incluindo biomas sem inimigos).
SELECT biome.name AS bioma, count(enemy_biome.id_enemy) AS inimigos
FROM biome
LEFT JOIN enemy_biome ON enemy_biome.id_biome = biome.id_biome
GROUP BY biome.name
ORDER BY inimigos DESC, bioma;

-- 14. Atualização: Iruziky usa uma Life Crystal (+20 de vida máxima)
-- e ela sai do Piggy Bank.
BEGIN;
UPDATE player SET max_hp = max_hp + 20, hp = hp + 20 WHERE name = 'Iruziky';
DELETE FROM inventory_item
WHERE id_item = (SELECT id_item FROM item WHERE name = 'Life Crystal')
  AND id_inventory = (SELECT inventory.id_inventory FROM inventory
                      INNER JOIN player ON player.id_player = inventory.id_player
                      WHERE player.name = 'Iruziky' AND inventory.type = 'piggy_bank');
SELECT name, hp, max_hp FROM player WHERE name = 'Iruziky';
ROLLBACK;

-- 15. Alteração de tabela: adiciona uma coluna de preço de venda,
-- preenche e remove (dentro de uma transação, para não alterar o banco).
BEGIN;
ALTER TABLE item ADD COLUMN sell_price integer;
UPDATE item SET sell_price = item.id_item*2;
SELECT name, sell_price FROM item LIMIT 10;
ALTER TABLE item DROP COLUMN sell_price;
ROLLBACK;

-- 16. Restrições em ação: cada comando abaixo FALHA de propósito.
-- CHECK: vida maior que a vida máxima.
BEGIN;
UPDATE player SET hp = 999 WHERE name = 'Heitor';
ROLLBACK;

-- CHECK: classe que não existe.
BEGIN;
INSERT INTO player (name, hp, max_hp, mana, max_mana, class) VALUES ('Teste', 100, 100, 20, 20, 'rogue');
ROLLBACK;

-- CHECK: chance de drop acima de 100%.
BEGIN;
INSERT INTO enemy_drop (id_enemy, id_item, chance) VALUES (13, 5, 1.5);
ROLLBACK;

-- UNIQUE: segundo inventário principal para o mesmo jogador.
BEGIN;
INSERT INTO inventory (id_player, type, capacity) VALUES (1, 'main', 50);
ROLLBACK;

-- FOREIGN KEY: item que não existe.
BEGIN;
INSERT INTO inventory_item (id_inventory, slot, id_item) VALUES (1, 49, 9999);
ROLLBACK;

-- FOREIGN KEY (RESTRICT): apagar um item que está em uso (inventários e receitas).
BEGIN;
DELETE FROM item WHERE name = 'Wood';
ROLLBACK;

-- ON DELETE CASCADE: apagar um jogador apaga seus inventários e itens.
BEGIN;
DELETE FROM player WHERE name = 'Davi';
SELECT count(*) AS inventarios_do_davi FROM inventory WHERE id_player = 3;
ROLLBACK;
