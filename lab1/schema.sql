SET client_encoding = 'UTF8';

DROP TABLE IF EXISTS tickets, orders, customers, event_prices, events,
                     seats, sectors, venues, organizers, categories CASCADE;


CREATE TABLE categories (
    id    INTEGER     GENERATED ALWAYS AS IDENTITY,
    name  VARCHAR(50) NOT NULL,

    CONSTRAINT pk_categories      PRIMARY KEY (id),
    CONSTRAINT uq_categories_name UNIQUE (name)
);


CREATE TABLE organizers (
    id     INTEGER      GENERATED ALWAYS AS IDENTITY,
    name   VARCHAR(200) NOT NULL,
    inn    VARCHAR(12)  NOT NULL,
    email  VARCHAR(254) NOT NULL,
    phone  VARCHAR(16)  NOT NULL,

    CONSTRAINT pk_organizers        PRIMARY KEY (id),
    CONSTRAINT uq_organizers_inn    UNIQUE (inn),
    CONSTRAINT chk_organizers_inn   CHECK (length(inn) IN (10, 12) AND translate(inn, '0123456789', '') = ''),
    CONSTRAINT chk_organizers_email CHECK (email LIKE '%_@_%.__%' AND email = lower(email)),
    CONSTRAINT chk_organizers_phone CHECK (phone LIKE '+%' AND length(phone) BETWEEN 11 AND 16
                                           AND translate(substr(phone, 2), '0123456789', '') = '')
);


CREATE TABLE venues (
    id       INTEGER      GENERATED ALWAYS AS IDENTITY,
    name     VARCHAR(150) NOT NULL,
    city     VARCHAR(100) NOT NULL,
    address  VARCHAR(255) NOT NULL,

    CONSTRAINT pk_venues         PRIMARY KEY (id),
    CONSTRAINT uq_venues_address UNIQUE (city, address)
);


CREATE TABLE sectors (
    id        INTEGER      GENERATED ALWAYS AS IDENTITY,
    venue_id  INTEGER      NOT NULL,
    name      VARCHAR(100) NOT NULL,

    CONSTRAINT pk_sectors            PRIMARY KEY (id),
    CONSTRAINT fk_sectors_venue      FOREIGN KEY (venue_id)
        REFERENCES venues (id) ON DELETE CASCADE,
    CONSTRAINT uq_sectors_venue_name UNIQUE (venue_id, name)
);


CREATE TABLE seats (
    sector_id  INTEGER  NOT NULL,
    row_no     SMALLINT NOT NULL,
    seat_no    SMALLINT NOT NULL,

    CONSTRAINT pk_seats         PRIMARY KEY (sector_id, row_no, seat_no),
    CONSTRAINT fk_seats_sector  FOREIGN KEY (sector_id)
        REFERENCES sectors (id) ON DELETE CASCADE,
    CONSTRAINT chk_seats_row    CHECK (row_no > 0),
    CONSTRAINT chk_seats_number CHECK (seat_no > 0)
);


CREATE TABLE events (
    id            INTEGER      GENERATED ALWAYS AS IDENTITY,
    title         VARCHAR(200) NOT NULL,
    category_id   INTEGER,
    organizer_id  INTEGER      NOT NULL,
    venue_id      INTEGER      NOT NULL,
    starts_at     TIMESTAMPTZ  NOT NULL,
    ends_at       TIMESTAMPTZ  NOT NULL,
    age_limit     SMALLINT     NOT NULL DEFAULT 0,
    status        VARCHAR(20)  NOT NULL DEFAULT 'announced',
    description   TEXT,

    CONSTRAINT pk_events            PRIMARY KEY (id),
    CONSTRAINT fk_events_category   FOREIGN KEY (category_id)
        REFERENCES categories (id) ON DELETE SET NULL,
    CONSTRAINT fk_events_organizer  FOREIGN KEY (organizer_id)
        REFERENCES organizers (id) ON DELETE RESTRICT,
    CONSTRAINT fk_events_venue      FOREIGN KEY (venue_id)
        REFERENCES venues (id) ON DELETE RESTRICT,
    CONSTRAINT chk_events_period    CHECK (ends_at > starts_at),
    CONSTRAINT chk_events_age_limit CHECK (age_limit IN (0, 6, 12, 16, 18)),
    CONSTRAINT chk_events_status    CHECK (status IN ('announced', 'on_sale', 'cancelled', 'finished'))
);


CREATE TABLE event_prices (
    event_id   INTEGER       NOT NULL,
    sector_id  INTEGER       NOT NULL,
    price      NUMERIC(10,2) NOT NULL,

    CONSTRAINT pk_event_prices        PRIMARY KEY (event_id, sector_id),
    CONSTRAINT fk_event_prices_event  FOREIGN KEY (event_id)
        REFERENCES events (id) ON DELETE CASCADE,
    CONSTRAINT fk_event_prices_sector FOREIGN KEY (sector_id)
        REFERENCES sectors (id) ON DELETE RESTRICT,
    CONSTRAINT chk_event_prices_price CHECK (price > 0)
);


CREATE TABLE customers (
    id             INTEGER      GENERATED ALWAYS AS IDENTITY,
    last_name      VARCHAR(50)  NOT NULL,
    first_name     VARCHAR(50)  NOT NULL,
    middle_name    VARCHAR(50),
    email          VARCHAR(254) NOT NULL,
    phone          VARCHAR(16),
    registered_at  TIMESTAMPTZ  NOT NULL DEFAULT now(),

    CONSTRAINT pk_customers        PRIMARY KEY (id),
    CONSTRAINT uq_customers_email  UNIQUE (email),
    CONSTRAINT uq_customers_phone  UNIQUE (phone),
    CONSTRAINT chk_customers_email CHECK (email LIKE '%_@_%.__%' AND email = lower(email)),
    CONSTRAINT chk_customers_phone CHECK (phone LIKE '+%' AND length(phone) BETWEEN 11 AND 16
                                          AND translate(substr(phone, 2), '0123456789', '') = '')
);


CREATE TABLE orders (
    id           BIGINT      GENERATED ALWAYS AS IDENTITY,
    customer_id  INTEGER     NOT NULL,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT now(),
    status       VARCHAR(20) NOT NULL DEFAULT 'new',
    paid_at      TIMESTAMPTZ,

    CONSTRAINT pk_orders          PRIMARY KEY (id),
    CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id)
        REFERENCES customers (id) ON DELETE RESTRICT,
    CONSTRAINT chk_orders_status  CHECK (status IN ('new', 'paid', 'cancelled')),
    CONSTRAINT chk_orders_payment CHECK (
        (status = 'paid'  AND paid_at IS NOT NULL) OR
        (status <> 'paid' AND paid_at IS NULL)
    ),
    CONSTRAINT chk_orders_paid_at CHECK (paid_at >= created_at)
);


CREATE TABLE tickets (
    id         BIGINT        GENERATED ALWAYS AS IDENTITY,
    order_id   BIGINT        NOT NULL,
    event_id   INTEGER       NOT NULL,
    sector_id  INTEGER       NOT NULL,
    row_no     SMALLINT      NOT NULL,
    seat_no    SMALLINT      NOT NULL,
    price      NUMERIC(10,2) NOT NULL,
    code       UUID          NOT NULL DEFAULT gen_random_uuid(),

    CONSTRAINT pk_tickets        PRIMARY KEY (id),
    CONSTRAINT fk_tickets_order  FOREIGN KEY (order_id)
        REFERENCES orders (id) ON DELETE CASCADE,
    CONSTRAINT fk_tickets_price  FOREIGN KEY (event_id, sector_id)
        REFERENCES event_prices (event_id, sector_id) ON DELETE RESTRICT,
    CONSTRAINT fk_tickets_seat   FOREIGN KEY (sector_id, row_no, seat_no)
        REFERENCES seats (sector_id, row_no, seat_no) ON DELETE RESTRICT,
    CONSTRAINT uq_tickets_code   UNIQUE (code),
    CONSTRAINT uq_tickets_place  UNIQUE (event_id, sector_id, row_no, seat_no),
    CONSTRAINT chk_tickets_price CHECK (price >= 0)
);


COMMENT ON TABLE categories   IS 'Категории мероприятий';
COMMENT ON TABLE organizers   IS 'Организаторы мероприятий';
COMMENT ON TABLE venues       IS 'Площадки';
COMMENT ON TABLE sectors      IS 'Секторы площадок';
COMMENT ON TABLE seats        IS 'Места в секторах';
COMMENT ON TABLE events       IS 'Мероприятия';
COMMENT ON TABLE event_prices IS 'Цены на сектора для мероприятия';
COMMENT ON TABLE customers    IS 'Покупатели';
COMMENT ON TABLE orders       IS 'Заказы';
COMMENT ON TABLE tickets      IS 'Билеты';
