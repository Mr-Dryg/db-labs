BEGIN;

CREATE TYPE booking_status AS ENUM ('pending', 'confirmed', 'completed', 'cancelled');

ALTER TABLE booking
    ADD COLUMN status booking_status NOT NULL DEFAULT 'confirmed',
    ADD COLUMN cancel_reason TEXT;

ALTER TABLE booking
    ALTER COLUMN status SET DEFAULT 'pending',
    ADD CONSTRAINT not_empty_cancel_reason CHECK (
        (status = 'cancelled' AND cancel_reason IS NOT NULL AND cancel_reason <> '')
        OR
        (status <> 'cancelled' AND cancel_reason IS NULL)
    );

COMMIT;