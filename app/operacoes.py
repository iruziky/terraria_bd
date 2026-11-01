def list_players(conn):
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT name, hp || '/' || max_hp, mana || '/' || max_mana, class, team,
                   is_alive, coins, general_stats ->> 'defense'
            FROM player
            ORDER BY id_player
            """
        )
        return cur.fetchall()
