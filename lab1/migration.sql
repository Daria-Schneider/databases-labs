
BEGIN;

ALTER TABLE events DROP CONSTRAINT chk_events_status;
ALTER TABLE events ADD CONSTRAINT chk_events_status
    CHECK (status IN ('announced', 'on_sale', 'postponed', 'cancelled', 'finished'));

UPDATE events SET status = 'postponed' WHERE id = 4;


CREATE TABLE price_increases (
    event_id      INTEGER  NOT NULL REFERENCES events (id) ON DELETE CASCADE,
    days_before   SMALLINT NOT NULL CHECK (days_before > 0),
    increase_pct  SMALLINT NOT NULL CHECK (increase_pct BETWEEN 1 AND 200),
    PRIMARY KEY (event_id, days_before)
);

INSERT INTO price_increases (event_id, days_before, increase_pct) VALUES
    (1, 30, 10),
    (1, 7, 25),
    (1, 1, 50);

COMMIT;
