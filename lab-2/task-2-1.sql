-- 2.1.1. Подробная информация о бронях (актуальная версия, стоимость на лету)
SELECT b.id AS booking_id,
       c.name AS client,
       COALESCE(m.name, 'не назначен') AS manager,
       l.name AS location,
       r.name AS room,
       b.status,
       b.booked_seats,
       bc.start_time,
       bc.end_time,
       ROUND(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
             * r.price_per_hour * (1 - c.discount), 2) AS total_price
FROM booking b
JOIN client c          ON c.id = b.client_id
LEFT JOIN manager m    ON m.id = b.manager_id
JOIN booking_change bc ON bc.booking_id = b.id
                      AND bc.created_at = (SELECT MAX(x.created_at)
                                           FROM booking_change x
                                           WHERE x.booking_id = b.id)
JOIN room r            ON r.id = bc.room_id
JOIN location l        ON l.id = r.location_id
ORDER BY bc.start_time;


-- 2.1.2. Клиенты без единой брони (с их любимой локацией, если она есть)
SELECT c.id, c.name, c.email, COALESCE(l.name, 'не указана') AS favorite_location
FROM client c
LEFT JOIN location l ON l.id = c.favorite_location
LEFT JOIN booking b  ON b.client_id = c.id
WHERE b.id IS NULL
ORDER BY c.id;   -- ожидаются клиенты 13, 14, 15


-- 2.1.3. Состоявшиеся брони, где зал был заполнен не менее чем на 80%
-- и у клиента есть скидка
SELECT b.id AS booking_id, c.name AS client, c.discount, l.name AS location,
       r.name AS room, r.capacity, b.booked_seats,
       ROUND(100.0 * b.booked_seats / r.capacity, 1) AS occupancy_pct
FROM booking b
JOIN client c          ON c.id = b.client_id
JOIN booking_change bc ON bc.booking_id = b.id
                      AND bc.created_at = (SELECT MAX(x.created_at)
                                           FROM booking_change x
                                           WHERE x.booking_id = b.id)
JOIN room r            ON r.id = bc.room_id
JOIN location l        ON l.id = r.location_id
WHERE b.status = 'completed'
  AND c.discount > 0
  AND r.capacity > 0
  AND b.booked_seats >= 0.8 * r.capacity
ORDER BY occupancy_pct DESC, b.id;