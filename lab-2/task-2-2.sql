-- 2.2.1. Показатели по локациям (только состоявшиеся брони)
SELECT l.name AS location,
       COUNT(*) AS bookings,
       ROUND(SUM(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600), 1) AS total_hours,
       ROUND(AVG(b.booked_seats), 1) AS avg_seats,
       MAX(r.price_per_hour) AS max_hour_price
FROM booking b
JOIN booking_change bc ON bc.booking_id = b.id
                      AND bc.created_at = (SELECT MAX(x.created_at)
                                           FROM booking_change x
                                           WHERE x.booking_id = b.id)
JOIN room r     ON r.id = bc.room_id
JOIN location l ON l.id = r.location_id
WHERE b.status = 'completed'
GROUP BY l.id, l.name
ORDER BY bookings DESC;


-- 2.2.2. Постоянные клиенты: >= 2 состоявшихся броней и сумма трат > 30000 (HAVING)
SELECT c.name AS client,
       COUNT(*) AS completed_bookings,
       ROUND(SUM(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
                 * r.price_per_hour * (1 - c.discount)), 2) AS total_spent,
       ROUND(AVG(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
                 * r.price_per_hour * (1 - c.discount)), 2) AS avg_check
FROM client c
JOIN booking b         ON b.client_id = c.id
JOIN booking_change bc ON bc.booking_id = b.id
                      AND bc.created_at = (SELECT MAX(x.created_at)
                                           FROM booking_change x
                                           WHERE x.booking_id = b.id)
JOIN room r            ON r.id = bc.room_id
WHERE b.status = 'completed'
GROUP BY c.id, c.name
HAVING COUNT(*) >= 2
   AND SUM(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
           * r.price_per_hour * (1 - c.discount)) > 30000
ORDER BY total_spent DESC;


-- 2.2.3. Сравнение месяцев: выручка, потери от отмен, средний чек, изменение к прошлому месяцу
SELECT TO_CHAR(m.month, 'YYYY-MM') AS year_month,
       m.bookings,
       m.cancelled,
       ROUND(m.income, 2) AS income,
       ROUND(m.lost, 2) AS lost,
       ROUND(m.avg_check, 2) AS avg_check,
       ROUND(m.income - LAG(m.income) OVER (ORDER BY m.month), 2) AS income_change
FROM (
    SELECT DATE_TRUNC('month', bc.start_time) AS month,
           COUNT(*) AS bookings,
           COUNT(*) FILTER (WHERE b.status = 'cancelled') AS cancelled,
           COALESCE(SUM(cost) FILTER (WHERE b.status = 'completed'), 0) AS income,
           COALESCE(SUM(cost) FILTER (WHERE b.status = 'cancelled'), 0) AS lost,
           AVG(cost) FILTER (WHERE b.status = 'completed') AS avg_check
    FROM booking b
    JOIN client c          ON c.id = b.client_id
    JOIN booking_change bc ON bc.booking_id = b.id
                          AND bc.created_at = (SELECT MAX(x.created_at)
                                               FROM booking_change x
                                               WHERE x.booking_id = b.id)
    JOIN room r            ON r.id = bc.room_id
    CROSS JOIN LATERAL (
        SELECT EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
               * r.price_per_hour * (1 - c.discount) AS cost
    ) k
    GROUP BY DATE_TRUNC('month', bc.start_time)
) m
ORDER BY m.month;
