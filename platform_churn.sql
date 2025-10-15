with churned as (
    SELECT
        platform, 
        COUNT (user_id) as churned
    FROM 
        spotify_user_analysis
    WHERE 
        is_churned = TRUE
    GROUP BY
        platform
),

not_churned as (
    SELECT
        platform,
        COUNT(user_id) as not_churned
    FROM
        spotify_user_analysis
    WHERE
        is_churned = FALSE
    GROUP BY
        platform
)

SELECT
    cte_1.platform,
    cte_2.not_churned as current_users,
    cte_1.churned as former_users,
-- I went with the difference between former and current users
-- because the user base is of the similar size on all three platforms
-- in the context of this dataset. Ratios would not be insightful in this case.
    cte_2.not_churned - cte_1.churned as difference
FROM
    churned as cte_1
INNER JOIN
    not_churned as cte_2 ON cte_2.platform = cte_1.platform
GROUP BY
    cte_1.platform, cte_1.churned, cte_2.not_churned
ORDER BY
    difference DESC
