BEGIN;

CREATE TABLE equipment (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name varchar(128) NOT NULL UNIQUE
);

CREATE TABLE equipment_room (
    equipment_id bigint NOT NULL REFERENCES equipment(id) ON DELETE CASCADE,
    room_id bigint NOT NULL REFERENCES room(id) ON DELETE CASCADE,
    quantity int NOT NULL DEFAULT 1 CHECK (quantity > 0),

    PRIMARY KEY (equipment_id, room_id)
);

COMMIT;