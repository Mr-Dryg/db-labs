-- 3.1. Залы, цена часа которых выше средней по их локации
SELECT r.id, r.name, l.name AS location, r.price_per_hour,
       ROUND((SELECT AVG(r2.price_per_hour) FROM room r2 WHERE r2.location_id = r.location_id), 2) AS location_avg
FROM room r
JOIN location l ON l.id = r.location_id
WHERE r.price_per_hour > (SELECT AVG(r2.price_per_hour)
                          FROM room r2
                          WHERE r2.location_id = r.location_id)
ORDER BY l.name, r.price_per_hour DESC;
-- ожидаются: Гамма, Сириус, Квант, Мини


-- 3.2. EXISTS: клиенты, у которых есть хотя бы одна состоявшаяся бронь на 40+ мест
SELECT c.id, c.name, c.discount
FROM client c
WHERE EXISTS (
    SELECT 1
    FROM booking b
    WHERE b.client_id = c.id
      AND b.status = 'completed'
      AND b.booked_seats >= 40
)
ORDER BY c.id;   -- ожидаются клиенты 4, 9, 11


-- 3.3. NOT EXISTS: залы, в которых ни разу не прошло состоявшееся мероприятие
-- (кандидаты на пересмотр цены или вывод из эксплуатации)
SELECT r.id, r.name, l.name AS location, r.capacity, r.price_per_hour
FROM room r
JOIN location l ON l.id = r.location_id
WHERE NOT EXISTS (
    SELECT 1
    FROM booking_change bc
    JOIN booking b ON b.id = bc.booking_id
    WHERE bc.room_id = r.id
      AND b.status = 'completed'
)
ORDER BY r.id;   -- ожидаются залы 10, 11, 12


-- 3.4. Коррелированный подзапрос: клиенты, у которых были состоявшиеся мероприятия,
-- но последнее было более 30 дней назад (кандидаты на возвращение)
SELECT c.id, c.name,
       (SELECT COUNT(*)
        FROM booking b
        WHERE b.client_id = c.id AND b.status = 'completed') AS completed_bookings,
       (SELECT MAX(bc.start_time)
        FROM booking b
        JOIN booking_change bc ON bc.booking_id = b.id
                              AND bc.created_at = (SELECT MAX(x.created_at)
                                                   FROM booking_change x
                                                   WHERE x.booking_id = b.id)
        WHERE b.client_id = c.id AND b.status = 'completed') AS last_event
FROM client c
WHERE (SELECT MAX(bc.start_time)
       FROM booking b
       JOIN booking_change bc ON bc.booking_id = b.id
                             AND bc.created_at = (SELECT MAX(x.created_at)
                                                  FROM booking_change x
                                                  WHERE x.booking_id = b.id)
       WHERE b.client_id = c.id AND b.status = 'completed') < now() - INTERVAL '30 days'
ORDER BY last_event;


