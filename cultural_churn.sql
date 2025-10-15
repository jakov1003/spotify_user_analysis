
with churned_culture as (
    SELECT
        -- Since this dataset only includes six countries,
        -- I thought that grouping them by cultural similarities and/or geography
        -- could help derive more actionable insights.
        CASE
        WHEN country IN ('US', 'UK', 'CA', 'AU') THEN 'Anglosphere'
        WHEN country IN ('FR', 'DE') THEN 'France-Germany'
        WHEN country IN ('IN', 'PK') THEN 'India-Pakistan'
        ELSE 'Unknown'
        END AS cultural_groups,
        COUNT(user_id) as churned_count
    FROM 
        spotify_user_analysis
    WHERE 
        is_churned = TRUE
    GROUP BY
        cultural_groups
),

not_churned_culture as (
    SELECT
        CASE 
        WHEN country IN ('US', 'UK', 'CA', 'AUS') THEN 'Anglosphere'
        WHEN country IN ('FR', 'DE') THEN 'France-Germany'
        WHEN country IN ('IN', 'PK') THEN 'India-Pakistan'
        ELSE 'Unknown'
        END as cultural_groups,
    COUNT(user_id) as not_churned_count
    FROM 
        spotify_user_analysis
    WHERE 
        is_churned = FALSE
    GROUP BY
        cultural_groups
)

SELECT
    cte_1.cultural_groups,
    cte_2.not_churned_count as current_users,
    cte_1.churned_count as former_users,
-- I used ratios of current to former users instead of differences
-- because one cultural group has significantly more users 
-- than the other two in this dataset.
-- Casting was required due to situation-specific constraints
-- of the division operation and the ROUND function.
    ROUND((cte_2.not_churned_count::float / cte_1.churned_count)::numeric, 2) AS current_to_former_ratio
FROM
    churned_culture as cte_1
INNER JOIN
    not_churned_culture as cte_2 ON cte_2.cultural_groups = cte_1.cultural_groups
GROUP BY
    cte_1.cultural_groups, cte_1.churned_count, cte_2.not_churned_count
ORDER BY
    current_to_former_ratio DESC
