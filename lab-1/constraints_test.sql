-- 1. CHECK: end_time > start_time в location
INSERT INTO location (name, address, start_time, end_time)
VALUES ('Плохая локация', 'г. Москва, ул. Тестовая, д. 1', '18:00', '09:00');

-- 2. CHECK: формат email в manager
INSERT INTO manager (name, email, phone, location_id)
VALUES ('Тестов Тест', 'не-почта', '+79001112233', 1);

-- 3. CHECK: формат телефона в client
INSERT INTO client (name, email, phone)
VALUES ('Плохой клиент', 'bad@client.ru', '8-900-123-45-67');

-- 4. CHECK: discount в диапазоне [0, 0.50] в client
INSERT INTO client (name, email, phone, discount)
VALUES ('Жадный клиент', 'greedy@client.ru', '+79109998877', 0.75);

-- 5. UNIQUE: address в location
INSERT INTO location (name, address, start_time, end_time)
VALUES ('Дубль адреса', 'г. Москва, ул. Тверская, д. 1', '08:00', '22:00');

-- 6. UNIQUE: email в client
INSERT INTO client (name, email, phone)
VALUES ('Дубль email', 'romashka@mail.ru', '+79107776655');

-- 7. UNIQUE (name, location_id): комната с тем же именем в той же локации
INSERT INTO room (name, capacity, price_per_hour, location_id)
VALUES ('Зал «Амфитеатр»', 20, 1000.00, 1);

-- 8. UNIQUE (start_time, end_time, room_id): двойное бронирование
INSERT INTO booking (booked_seats, start_time, end_time, price, client_id, room_id)
VALUES (10, '2026-10-01 10:00+03', '2026-10-01 14:00+03', 20000, 2, 1);
