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
SELECT item.name, 'receita em ' || coalesce(estacao.name, 'à mão')
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
