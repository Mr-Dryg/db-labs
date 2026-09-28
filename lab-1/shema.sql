CREATE TABLE location (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    address text NOT NULL UNIQUE,
    start_time time NOT NULL,
    end_time time NOT NULL,

    CONSTRAINT check_location_work_time CHECK (end_time > start_time)
);

CREATE TABLE manager (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE CHECK (email LIKE '%@%.%'),
    phone text NOT NULL UNIQUE CHECK (phone ~ '^\+[1-9]\d{1,14}$'),
    location_id bigint NOT NULL REFERENCES location(id) ON DELETE RESTRICT
);

CREATE TABLE room (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    capacity int NOT NULL DEFAULT 0 CHECK (capacity >= 0),
    price_per_hour numeric(10, 2) NOT NULL DEFAULT 0.00 CHECK (price_per_hour >= 0),
    location_id bigint NOT NULL REFERENCES location(id) ON DELETE CASCADE,

    CONSTRAINT unique_room_at_location UNIQUE (name, location_id)
);

CREATE TABLE client (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL,
    email text NOT NULL UNIQUE CHECK (email LIKE '%@%.%'),
    phone text NOT NULL UNIQUE CHECK (phone ~ '^\+[1-9]\d{1,14}$'),
    discount numeric(3, 2) NOT NULL DEFAULT 0.00 CHECK (0.00 <= discount AND discount <= 0.50),
    favorite_location bigint REFERENCES location(id) ON DELETE SET NULL
);

CREATE TABLE booking (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booked_seats integer NOT NULL CHECK (booked_seats > 0),
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    price numeric(10, 2) NOT NULL DEFAULT 0 CHECK (price >= 0),
    client_id bigint NOT NULL REFERENCES client(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES room(id) ON DELETE RESTRICT,
    manager_id bigint REFERENCES manager(id) ON DELETE SET NULL,

    CONSTRAINT check_booking_time CHECK (end_time > start_time),
    CONSTRAINT unique_booking_time_at_room UNIQUE (start_time, end_time, room_id)
);