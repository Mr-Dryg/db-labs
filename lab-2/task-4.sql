WITH actual_booking_change AS (
    SELECT id, booking_id, room_id, start_time, end_time, created_at
    FROM (
        SELECT
            id,
            booking_id,
            room_id,
            start_time,
            end_time,
            created_at,
            ROW_NUMBER() OVER (PARTITION BY booking_id ORDER BY created_at DESC, id DESC) AS rn
        FROM booking_change
    )
    WHERE rn = 1
), booking_price AS (
    SELECT
        b.id AS booking_id,
        l.id AS location_id,
        b.status,
        DATE_TRUNC('month', bc.start_time) AS month,
        EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600 AS hours,
        r.price_per_hour * EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600 * (1 - c.discount) AS price
    FROM actual_booking_change bc
    JOIN booking b ON b.id = bc.booking_id
    JOIN client c ON c.id = b.client_id
    JOIN room r ON r.id = bc.room_id
    JOIN location l ON l.id = r.location_id
), statistic AS (
    SELECT 
        location_id,
        month,
        SUM(price) FILTER (WHERE status = 'completed') AS income,
        SUM(price) FILTER (WHERE status = 'cancelled') AS lost,
        COUNT(*) AS count_all,
        COUNT(*) FILTER (WHERE status = 'cancelled') AS count_cancelled,
        SUM(hours) FILTER (WHERE status = 'completed') AS completed_hours
    FROM booking_price
    GROUP BY month, location_id
)
SELECT
    TO_CHAR(s.month, 'YYYY-MM') AS year_month,
    l.name AS location,
    ROUND(COALESCE(s.completed_hours, 0), 1) AS completed_hours,
    COALESCE(s.income, 0) AS income,
    COALESCE(
        ROUND(100 * COALESCE(s.income, 0)
        / NULLIF(SUM(s.income) OVER (PARTITION BY s.month), 0), 1),
        0
    ) AS income_month_share,
    COALESCE(s.lost, 0) AS lost,
    COALESCE(s.count_all, 0) AS count_all,
    COALESCE(s.count_cancelled, 0) AS count_cancelled,
    COALESCE(
        ROUND(100 * s.count_cancelled::numeric / NULLIF(s.count_all, 0), 1),
        0
    ) AS cancel_share
FROM location l
LEFT JOIN statistic s ON s.location_id = l.id
ORDER BY s.month ASC, s.income DESC NULLS LAST, l.name ASC;