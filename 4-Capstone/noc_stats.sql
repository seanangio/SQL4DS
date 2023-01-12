WITH noc_performance AS (
    SELECT g.year, g.season, g.city, n.noc, 
        COUNT(*) AS participants,
        COUNT(pe.medal_id) AS medals,
        SUM(CASE WHEN medal_id = 1 THEN 1
            ELSE 0 END) AS golds,
        SUM(COUNT(*)) OVER (
            PARTITION BY noc
            ORDER BY year, season
            ROWS BETWEEN UNBOUNDED PRECEDING 
                AND CURRENT ROW) AS cum_participants,
        SUM(COUNT(pe.medal_id)) OVER (
            PARTITION BY noc
            ORDER BY year, season
            ROWS BETWEEN UNBOUNDED PRECEDING 
                AND CURRENT ROW) AS cum_medals,
        SUM(SUM(CASE WHEN medal_id = 1 THEN 1
            ELSE 0 END)) OVER (
            PARTITION BY noc
            ORDER BY year, season
            ROWS BETWEEN UNBOUNDED PRECEDING 
                AND CURRENT ROW) AS cum_golds
    FROM performances pe
    JOIN participants pa
        ON pe.participant_id = pa.id 
    JOIN games g
        ON g.id = pa.games_id
    JOIN nocs n
        ON n.id = pa.noc_id
    WHERE n.noc = $1 --AND g.season = $2
    GROUP BY g.year, g.season, g.city, n.noc
    ORDER BY g.year
)

SELECT year, season, city, noc, t.* 
FROM noc_performance np
    CROSS JOIN LATERAL (
    VALUES 
        (np.cum_participants, 'participants'),
        (np.cum_medals, 'medals'),
        (np.cum_golds, 'golds')
    ) AS t(value, stat)
ORDER BY year
