BEGIN;

-- 1. Локации (локация 5 без залов, локация 4 без менеджеров)
INSERT INTO location (id, name, address, start_time, end_time)
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Бизнес-центр Север',     'ул. Тверская, 10',           '08:00', '22:00'),
(2, 'Коворкинг Центральный',  'ул. Арбат, 25',              '09:00', '21:00'),
(3, 'Технопарк Восток',       'ш. Энтузиастов, 5',          '07:00', '23:00'),
(4, 'Деловой квартал Юг',     'ул. Профсоюзная, 40',        '08:00', '20:00'),
(5, 'Офис-хаб Запад',         'Кутузовский пр-т, 12',       '10:00', '18:00');

-- 2. Менеджеры
INSERT INTO manager (id, name, email, phone, location_id)
OVERRIDING SYSTEM VALUE
VALUES
(1, 'Иванов Сергей',     'ivanov@rooms.example',   '+79001000101', 1),
(2, 'Крылова Анна',      'krylova@rooms.example',  '+79001000102', 1),
(3, 'Орлов Дмитрий',     'orlov@rooms.example',    '+79001000103', 2),
(4, 'Белова Мария',      'belova@rooms.example',   '+79001000104', 3),
(5, 'Громов Алексей',    'gromov@rooms.example',   '+79001000105', 3),
(6, 'Захарова Ольга',    'zakharova@rooms.example','+79001000106', 2);

-- 3. Клиенты (13, 14, 15 без бронирований; часть без любимой локации; скидка 0)
INSERT INTO client (id, name, email, phone, discount, favorite_location)
OVERRIDING SYSTEM VALUE
VALUES
(1,  'Смирнов Павел',     'smirnov@mail.example',   '+79112000001', 0.00, 1),
(2,  'Кузнецова Елена',   'kuznetsova@mail.example','+79112000002', 0.05, 2),
(3,  'Попов Игорь',       'popov@mail.example',     '+79112000003', 0.10, NULL),
(4,  'Васильева Ирина',   'vasileva@mail.example',  '+79112000004', 0.15, 1),
(5,  'Петров Андрей',     'petrov@mail.example',    '+79112000005', 0.00, NULL),
(6,  'Соколова Наталья',  'sokolova@mail.example',  '+79112000006', 0.20, 3),
(7,  'Михайлов Роман',    'mikhailov@mail.example', '+79112000007', 0.05, 2),
(8,  'Новикова Дарья',    'novikova@mail.example',  '+79112000008', 0.00, 3),
(9,  'Фёдоров Максим',    'fedorov@mail.example',   '+79112000009', 0.30, 1),
(10, 'Морозова Светлана', 'morozova@mail.example',  '+79112000010', 0.10, NULL),
(11, 'Волков Артём',      'volkov@mail.example',    '+79112000011', 0.00, 4),
(12, 'Алексеева Юлия',    'alekseeva@mail.example', '+79112000012', 0.25, 5),
(13, 'Лебедев Олег',      'lebedev@mail.example',   '+79112000013', 0.05, NULL),
(14, 'Семёнова Вера',     'semenova@mail.example',  '+79112000014', 0.00, 2),
(15, 'Егоров Виктор',     'egorov@mail.example',    '+79112000015', 0.15, NULL);

-- 4. Залы (10 и 12 никогда не бронировались; 11 бесплатный; 12 с нулевой вместимостью)
INSERT INTO room (id, name, capacity, price_per_hour, location_id)
OVERRIDING SYSTEM VALUE
VALUES
(1,  'Альфа',        10,  1500.00, 1),
(2,  'Бета',         20,  2500.00, 1),
(3,  'Гамма',        50,  6000.00, 1),
(4,  'Орион',         8,  1200.00, 2),
(5,  'Вега',         15,  2000.00, 2),
(6,  'Сириус',       30,  3500.00, 2),
(7,  'Атлас',        12,  1800.00, 3),
(8,  'Титан',        40,  5000.00, 3),
(9,  'Квант',       100, 12000.00, 3),
(10, 'Мини',          4,   800.00, 4),
(11, 'Открытый',      6,     0.00, 4),
(12, 'Резерв',        0,     0.00, 4);

-- 5. Бронирования (статус отмены хранится только здесь)
INSERT INTO booking (id, booked_seats, client_id, manager_id, status)
OVERRIDING SYSTEM VALUE
VALUES
-- август
(1,   8,  1,  1,    'completed'),
(2,  15,  2,  3,    'completed'),
(3,  30,  3,  4,    'completed'),
(4,  40,  4,  1,    'completed'),
(5,  10,  5,  2,    'completed'),
(6,  12,  6,  4,    'completed'),
(7,  25,  7,  3,    'completed'),
(8,   6,  1,  1,    'cancelled'),
(9,  20,  9,  NULL, 'cancelled'),
(10, 80, 11,  5,    'completed'),
(11,  7,  2,  3,    'completed'),
(12, 45,  4,  2,    'completed'),
-- сентябрь
(13,  9,  1,  1,    'completed'),
(14, 35,  6,  5,    'completed'),
(15,  5, 12,  6,    'completed'),
(16, 18,  3,  NULL, 'completed'),
(17, 14,  7,  3,    'completed'),
(18, 10,  8,  4,    'cancelled'),
(19, 50,  9,  1,    'completed'),
(20, 28, 10,  6,    'completed'),
(21, 15,  2,  3,    'completed'),
(22, 90, 11,  5,    'completed'),
(23, 20,  4,  2,    'cancelled'),
(24, 11,  6,  4,    'completed'),
-- октябрь / ноябрь
(25, 10,  1,  1,    'completed'),
(26, 15,  5,  2,    'completed'),
(27, 48,  9,  1,    'confirmed'),
(28, 20,  7,  6,    'confirmed'),
(29,  6, 12,  NULL, 'created'),
(30, 38,  8,  4,    'confirmed'),
(31,  8,  3,  NULL, 'created'),
(32, 30, 10,  6,    'cancelled'),
(33, 95,  6,  5,    'created'),
(34, 12,  2,  3,    'completed'),
(35,  3,  4,  2,    'completed'),
(36, 25,  9,  1,    'created');  -- 25 мест в зале на 20: намеренное превышение вместимости

-- 6. Изменения бронирований 
INSERT INTO booking_change (id, booking_id, room_id, start_time, end_time, created_at, reason)
OVERRIDING SYSTEM VALUE
VALUES
-- август
(1,  1,  1, '2026-08-04 10:00', '2026-08-04 12:00', '2026-07-28 09:15', NULL),
(2,  2,  5, '2026-08-05 14:00', '2026-08-05 17:00', '2026-07-30 11:00', NULL),
(3,  3,  8, '2026-08-07 09:00', '2026-08-07 13:00', '2026-08-01 10:30', NULL),
(4,  4,  3, '2026-08-11 10:00', '2026-08-11 16:00', '2026-08-02 12:00', NULL),
(5,  5,  2, '2026-08-12 15:00', '2026-08-12 18:00', '2026-08-03 16:20', NULL),
(6,  6,  7, '2026-08-14 11:00', '2026-08-14 14:00', '2026-08-05 09:00', NULL),
(7,  7,  6, '2026-08-18 13:00', '2026-08-18 16:00', '2026-08-08 14:40', NULL),
(8,  8,  1, '2026-08-19 10:00', '2026-08-19 11:00', '2026-08-10 10:00', NULL),
(9,  9,  2, '2026-08-20 12:00', '2026-08-20 15:00', '2026-08-10 13:00', NULL),
(10, 9,  2, '2026-08-21 12:00', '2026-08-21 15:00', '2026-08-15 09:30', 'Перенос по просьбе клиента'),
(12, 10, 9, '2026-08-25 09:00', '2026-08-25 18:00', '2026-08-12 11:00', NULL),
(13, 11, 4, '2026-08-26 10:00', '2026-08-26 12:00', '2026-08-16 10:00', NULL),
(14, 12, 3, '2026-08-28 09:00', '2026-08-28 17:00', '2026-08-18 15:00', NULL),
-- сентябрь
(16, 13, 1, '2026-09-02 10:00', '2026-09-02 13:00', '2026-08-25 10:00', NULL),
(17, 14, 8, '2026-09-04 10:00', '2026-09-04 15:00', '2026-08-27 12:00', NULL),
(18, 15, 4, '2026-09-08 16:00', '2026-09-08 18:00', '2026-09-01 09:00', NULL),
(19, 16, 2, '2026-09-09 11:00', '2026-09-09 14:00', '2026-09-01 13:00', NULL),
(20, 17, 5, '2026-09-11 09:00', '2026-09-11 12:00', '2026-09-03 10:00', NULL),
(21, 18, 7, '2026-09-15 12:00', '2026-09-15 14:00', '2026-09-05 10:00', NULL),
(23, 19, 3, '2026-09-16 10:00', '2026-09-16 14:00', '2026-09-04 11:00', NULL),
(24, 19, 3, '2026-09-17 10:00', '2026-09-17 14:00', '2026-09-10 12:00', 'Перенос на другую дату'),
(25, 19, 3, '2026-09-17 10:00', '2026-09-17 16:00', '2026-09-13 15:00', 'Продление времени'),
(26, 20, 6, '2026-09-18 13:00', '2026-09-18 17:00', '2026-09-08 09:00', NULL),
(27, 21, 5, '2026-09-22 14:00', '2026-09-22 16:00', '2026-09-12 10:00', NULL),
(28, 22, 9, '2026-09-24 08:00', '2026-09-24 20:00', '2026-09-10 14:00', NULL),
(29, 23, 2, '2026-09-25 10:00', '2026-09-25 12:00', '2026-09-15 10:00', NULL),
(31, 24, 7, '2026-09-29 15:00', '2026-09-29 18:00', '2026-09-19 16:00', NULL),
-- октябрь
(32, 25, 1, '2026-10-02 09:00', '2026-10-02 12:00', '2026-09-26 10:00', NULL),
(33, 26, 2, '2026-10-06 14:00', '2026-10-06 16:00', '2026-09-28 12:00', NULL),
(34, 34, 5, '2026-10-08 10:00', '2026-10-08 12:00', '2026-09-30 10:00', NULL),
(35, 35, 2, '2026-10-09 17:00', '2026-10-09 18:00', '2026-10-01 10:00', NULL),
(41, 32, 6, '2026-10-20 13:00', '2026-10-20 15:00', '2026-10-10 10:00', NULL),
(36, 27, 3, '2026-10-28 10:00', '2026-10-28 14:00', '2026-10-15 10:00', NULL),
(45, 27, 3, '2026-10-28 11:00', '2026-10-28 15:00', '2026-10-24 12:00', 'Изменено время начала'),
(37, 28, 6, '2026-10-29 13:00', '2026-10-29 16:00', '2026-10-16 11:00', NULL),
(38, 29, 11,'2026-10-30 10:00', '2026-10-30 12:00', '2026-10-22 10:00', NULL),
(39, 30, 8, '2026-10-30 09:00', '2026-10-30 15:00', '2026-10-20 10:00', NULL),
(40, 31, 4, '2026-10-31 11:00', '2026-10-31 13:00', '2026-10-23 14:00', NULL),
-- ноябрь
(43, 33, 9, '2026-11-05 09:00', '2026-11-05 19:00', '2026-10-24 11:00', NULL),
(44, 36, 2, '2026-11-10 10:00', '2026-11-10 13:00', '2026-10-25 10:00', NULL);

-- Синхронизация последовательностей после вставки с явными id
SELECT setval(pg_get_serial_sequence('location','id'),       (SELECT MAX(id) FROM location));
SELECT setval(pg_get_serial_sequence('manager','id'),        (SELECT MAX(id) FROM manager));
SELECT setval(pg_get_serial_sequence('client','id'),         (SELECT MAX(id) FROM client));
SELECT setval(pg_get_serial_sequence('room','id'),           (SELECT MAX(id) FROM room));
SELECT setval(pg_get_serial_sequence('booking','id'),        (SELECT MAX(id) FROM booking));
SELECT setval(pg_get_serial_sequence('booking_change','id'), (SELECT MAX(id) FROM booking_change));

COMMIT;


WITH actual_booking_change AS (
    SELECT booking_id, room_id, start_time, end_time
    FROM (
        SELECT booking_id, room_id, start_time, end_time,
               ROW_NUMBER() OVER (PARTITION BY booking_id
                                  ORDER BY created_at DESC, id DESC) AS rn
        FROM booking_change
    )
    WHERE rn = 1
), monthly AS (
    SELECT r.location_id,
           DATE_TRUNC('month', bc.start_time) AS month,
           COUNT(*) AS completed_bookings,
           SUM(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600
               * r.price_per_hour * (1 - c.discount)) AS income
    FROM actual_booking_change bc
    JOIN booking b ON b.id = bc.booking_id
    JOIN client c  ON c.id = b.client_id
    JOIN room r    ON r.id = bc.room_id
    WHERE b.status = 'completed'
    GROUP BY r.location_id, DATE_TRUNC('month', bc.start_time)
)
SELECT TO_CHAR(m.month, 'YYYY-MM') AS year_month,
       l.name AS location,
       m.completed_bookings,
       ROUND(m.income, 2) AS income,
       ROUND(SUM(m.income) OVER w, 2) AS cumulative_income,
       SUM(m.completed_bookings) OVER w AS cumulative_bookings,
       ROUND(100 * SUM(m.income) OVER w
             / SUM(m.income) OVER (PARTITION BY m.location_id), 1) AS cumulative_share_pct
FROM monthly m
JOIN location l ON l.id = m.location_id
WINDOW w AS (PARTITION BY m.location_id
             ORDER BY m.month
             ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
ORDER BY l.name, m.month;