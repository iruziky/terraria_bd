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
