BEGIN;

CREATE TABLE booking_change (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    booking_id bigint NOT NULL REFERENCES booking(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES room(id) ON DELETE RESTRICT,
    start_time timestamptz NOT NULL,
    end_time timestamptz NOT NULL,
    created_at timestamptz NOT NULL DEFAULT NOW(),
    reason TEXT,

    CONSTRAINT unique_active_booking_change UNIQUE(booking_id, created_at)
);

INSERT INTO booking_change (booking_id, room_id, start_time, end_time)
    SELECT id, room_id, start_time, end_time
    FROM booking;

ALTER TABLE booking
    DROP COLUMN start_time,
    DROP COLUMN end_time,
    DROP COLUMN room_id;

ALTER TABLE booking
  ADD COLUMN status text NOT NULL DEFAULT 'created'
  CHECK (status IN ('created', 'confirmed', 'completed', 'cancelled'));

COMMIT;