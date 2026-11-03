SELECT
    b.id AS booking_id,
    c.name as client,
    ROW_NUMBER() OVER (PARTITION BY b.id ORDER BY bc.created_at, bc.id) as change_number,
    l.name as location,
    r.name as room,
    bc.start_time,
    bc.end_time,
    ROUND(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600, 2) as hours,
    LAG(r.name) OVER (PARTITION BY b.id ORDER BY bc.created_at, bc.id) as prev_room,
    ROUND(
        EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600 -
            LAG(EXTRACT(EPOCH FROM (bc.end_time - bc.start_time)) / 3600)
            OVER (PARTITION BY b.id ORDER BY bc.created_at, bc.id),
        2
    ) as hours_change
FROM booking b
JOIN client c ON c.id = b.client_id
JOIN booking_change bc ON bc.booking_id = b.id
JOIN room r ON r.id = bc.room_id
JOIN location l ON l.id = r.location_id
ORDER BY b.id, change_number;