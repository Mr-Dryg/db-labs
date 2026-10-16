BEGIN;

CREATE TABLE loyalty_level (
    id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name text NOT NULL UNIQUE,
    discount numeric(3, 2) NOT NULL CHECK (discount >= 0.00 AND discount <= 0.50)
);

INSERT INTO loyalty_level (name, discount)
VALUES ('Level 0%', 0.00);

INSERT INTO loyalty_level (name, discount)
SELECT 'Level ' || (discount * 100)::int || '%', discount
FROM (SELECT DISTINCT discount FROM client WHERE discount <> 0.00)
ORDER BY discount;

ALTER TABLE client
    ADD COLUMN loyalty_level_id bigint REFERENCES loyalty_level(id) ON DELETE RESTRICT;

UPDATE client c
SET loyalty_level_id = l.id
FROM loyalty_level l
WHERE l.discount = c.discount;

ALTER TABLE client
    ALTER COLUMN loyalty_level_id SET NOT NULL,
    ALTER COLUMN loyalty_level_id SET DEFAULT 1,
    DROP COLUMN discount;

COMMIT;