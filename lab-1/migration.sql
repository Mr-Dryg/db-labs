BEGIN;

CREATE TABLE booking_change (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id bigint NOT NULL REFERENCES booking(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES room(id) ON DELETE RESTRICT,
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    reason TEXT,
    price numeric(10, 2) NOT NULL DEFAULT 0 CHECK (price >= 0),

    CONSTRAINT unique_active_booking_change UNIQUE(booking_id, created_at)
);

INSERT INTO booking_change (booking_id, room_id, start_time, end_time, price)
    SELECT id, room_id, start_time, end_time, price
    FROM booking;

ALTER TABLE booking
    DROP COLUMN start_time,
    DROP COLUMN end_time,
    DROP COLUMN price,
    DROP COLUMN room_id;

COMMIT;