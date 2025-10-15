with churned_age as (
    SELECT
        CASE 
        WHEN age BETWEEN 16 AND 24 THEN '16–24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        WHEN age BETWEEN 55 AND 59 THEN '55–59'
        ELSE 'Unknown'
        END AS age_groups,
        COUNT(user_id) as churned_count
    FROM 
        spotify_user_analysis
    WHERE 
        is_churned = TRUE
    GROUP BY
        age_groups
),

not_churned_age as (
    SELECT
        CASE 
        WHEN age BETWEEN 16 AND 24 THEN '16–24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35–44'
        WHEN age BETWEEN 45 AND 54 THEN '45–54'
        WHEN age BETWEEN 55 AND 59 THEN '55–59'
        ELSE 'Unknown'
        END AS age_groups,
    COUNT(user_id) as not_churned_count
    FROM 
        spotify_user_analysis
    WHERE 
        is_churned = FALSE
    GROUP BY
        age_groups
)

SELECT
    cte_1.age_groups,
    cte_2.not_churned_count as current_users,
    cte_1.churned_count as former_users,
-- I used ratios of current to former users instead of differences
-- because one age group has significantly fewer users than the others in this dataset.
-- Casting was required due to situation-specific constraints
-- of the division operation and the ROUND function.
    ROUND((cte_2.not_churned_count::float / cte_1.churned_count)::numeric, 2) AS current_to_former_ratio
FROM
    churned_age as cte_1
INNER JOIN
    not_churned_age as cte_2 ON cte_2.age_groups = cte_1.age_groups
GROUP BY
    cte_1.age_groups, cte_1.churned_count, cte_2.not_churned_count
ORDER BY
    current_to_former_ratio DESC





