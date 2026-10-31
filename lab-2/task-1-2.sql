-- 1.2.1. INSERT: новый клиент, бронь и первая версия брони (одним оператором)
WITH new_client AS (
    INSERT INTO client (name, email, phone, discount, favorite_location)
    SELECT 'Громова Татьяна', 'gromova@mail.example', '+7-911-200-00-16', 0.10, l.id
    FROM location l
    WHERE l.name = 'Технопарк Восток'
    RETURNING id
),
new_booking AS (
    INSERT INTO booking (booked_seats, client_id, manager_id, status)
    SELECT 14, c.id, m.id, 'created'
    FROM new_client c
    CROSS JOIN manager m
    WHERE m.email = 'belova@rooms.example'
    RETURNING id
)
INSERT INTO booking_change (booking_id, room_id, start_time, end_time, reason)
SELECT b.id, r.id,
       '2026-11-02 10:00 Europe/Moscow'::timestamptz,
       '2026-11-02 14:00 Europe/Moscow'::timestamptz,
       NULL
FROM new_booking b
CROSS JOIN room r
JOIN location l ON l.id = r.location_id
WHERE r.name = 'Титан' AND l.name = 'Технопарк Восток';

-- Проверка: ровно одна строка, total_price = 18000.00
SELECT c.name AS client, b.status, m.name AS manager, r.name AS room,
       bc.start_time, bc.end_time,
       ROUND(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
             * r.price_per_hour * (1 - c.discount), 2) AS total_price
FROM client c
LEFT JOIN booking b          ON b.client_id = c.id
LEFT JOIN manager m          ON m.id = b.manager_id
LEFT JOIN booking_change bc  ON bc.booking_id = b.id
LEFT JOIN room r             ON r.id = bc.room_id
WHERE c.email = 'gromova@mail.example';


-- 1.2.2. UPDATE: смена состояния одной брони (confirmed -> completed)
UPDATE booking
SET status = 'completed'
WHERE status = 'confirmed'
  AND client_id = (SELECT id FROM client WHERE email = 'fedorov@mail.example')
  AND EXISTS (
        SELECT 1
        FROM booking_change bc
        JOIN room r ON r.id = bc.room_id
        WHERE bc.booking_id = booking.id
          AND r.name = 'Квант'
  )
RETURNING id, status;   -- ожидается 1 строка (бронь 27)


-- 1.2.3. Массовый UPDATE по содержательному условию:
-- неподтверждённые брони, в которых мест больше, чем вмещает зал
-- (зал берётся из актуальной версии брони), автоматически отменяются
UPDATE booking b
SET status = 'cancelled'
WHERE b.status = 'created'
  AND b.booked_seats > (
        SELECT r.capacity
        FROM booking_change bc
        JOIN room r ON r.id = bc.room_id
        WHERE bc.booking_id = b.id
        ORDER BY bc.created_at DESC, bc.id DESC
        LIMIT 1
  )
RETURNING b.id, b.booked_seats, b.status;   -- ожидаются брони 33 и 36


-- 1.2.4. DELETE с учётом ограничений целостности

-- а) клиент без броней: удаляется без последствий
DELETE FROM client
WHERE email = 'egorov@mail.example'
RETURNING id, name;

-- б) клиент с бронями: каскад (D:C), смотрим до и после, затем откатываем
BEGIN;
SELECT (SELECT COUNT(*) FROM booking WHERE client_id = c.id) AS bookings,
       (SELECT COUNT(*) FROM booking_change bc
          JOIN booking b ON b.id = bc.booking_id
         WHERE b.client_id = c.id) AS changes
FROM client c WHERE c.email = 'smirnov@mail.example';

DELETE FROM client WHERE email = 'smirnov@mail.example';

SELECT COUNT(*) AS bookings_left
FROM booking b
WHERE b.client_id NOT IN (SELECT id FROM client);   -- всегда 0, брони удалены каскадом
SELECT COUNT(*) AS total_bookings FROM booking;     -- стало меньше на число броней клиента
ROLLBACK;

-- в) локация с менеджерами: RESTRICT (D:R), ожидается ошибка внешнего ключа
BEGIN;
DELETE FROM location WHERE name = 'Бизнес-центр Север';
-- ERROR: update or delete on table "location" violates foreign key constraint ...
ROLLBACK;   -- после ошибки транзакция прервана, откат обязателен


-- 1.2.5. ROLLBACK: демонстрация отмены
BEGIN;

SELECT status, COUNT(*) FROM booking GROUP BY status ORDER BY status;   -- до

UPDATE booking SET status = 'cancelled' WHERE status IN ('created', 'confirmed');

SELECT status, COUNT(*) FROM booking GROUP BY status ORDER BY status;   -- внутри транзакции

ROLLBACK;

SELECT status, COUNT(*) FROM booking GROUP BY status ORDER BY status;   -- после: как «до»

-- Бонус: SAVEPOINT и частичный откат
BEGIN;
UPDATE room SET price_per_hour = price_per_hour * 1.05 WHERE location_id = 1;   -- операция 1
SAVEPOINT after_prices;
DELETE FROM client WHERE email = 'lebedev@mail.example';                       -- операция 2
SELECT COUNT(*) FROM client;                       -- клиента уже нет
ROLLBACK TO SAVEPOINT after_prices;                -- откатываем только удаление
SELECT COUNT(*) FROM client;                       -- клиент вернулся
COMMIT;                                            -- цены на залы зафиксированы
