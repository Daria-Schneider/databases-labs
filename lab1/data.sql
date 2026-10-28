SET client_encoding = 'UTF8';

TRUNCATE tickets, orders, customers, event_prices, events,
         seats, sectors, venues, organizers, categories
         RESTART IDENTITY CASCADE;


INSERT INTO categories (name) VALUES
    ('Концерт'),
    ('Спектакль'),
    ('Стендап'),
    ('Детям'),
    ('Выставка');


INSERT INTO organizers (name, inn, email, phone) VALUES
    ('ООО «Звуковая волна»',      '7704123456',   'info@volna-events.example',   '+74951234567'),
    ('ИП Орлов Кирилл Андреевич', '165012345678', 'orlov.k@example.com',         '+79172345678'),
    ('АНО «Сцена без границ»',    '7810987654',   'office@scena-bg.example',     '+78129876543');


INSERT INTO venues (name, city, address) VALUES
    ('Концертный зал «Созвездие»',     'Москва',          'ул. Звёздная, 15'),
    ('Драматический театр «Полынь»',   'Санкт-Петербург', 'ул. Садовая, 12'),
    ('Арт-пространство «Котельная»',   'Казань',          'ул. Садовая, 12'),
    ('Летняя эстрада «Сосновый бор»',  'Нижний Новгород', 'Парковая аллея, 3');


INSERT INTO sectors (venue_id, name) VALUES
    (1, 'Партер'),
    (1, 'Амфитеатр'),
    (1, 'Балкон'),
    (2, 'Партер'),
    (2, 'Бельэтаж'),
    (2, 'Ложа'),
    (3, 'Танцпол'),
    (3, 'Балкон'),
    (4, 'Скамьи');


INSERT INTO seats (sector_id, row_no, seat_no)
SELECT hall.sector_id, r.row_no, s.seat_no
FROM (VALUES
        (1, 5, 10),
        (2, 3,  8),
        (3, 2,  6),
        (4, 4,  8),
        (5, 2,  6),
        (6, 1,  4),
        (7, 1, 30),
        (8, 2,  5),
        (9, 3, 10)
     ) AS hall (sector_id, rows_total, seats_per_row)
CROSS JOIN LATERAL generate_series(1, hall.rows_total)    AS r (row_no)
CROSS JOIN LATERAL generate_series(1, hall.seats_per_row) AS s (seat_no);


INSERT INTO events (title, category_id, organizer_id, venue_id,
                    starts_at, ends_at, age_limit, status, description) VALUES
    ('Симфонический вечер. Рахманинов', 1, 1, 1,
        '2026-11-14 19:00+03', '2026-11-14 21:30+03',  6, 'on_sale',
        'Второй фортепианный концерт и «Симфонические танцы»'),
    ('Группа «Северный маяк». Юбилейный тур', 1, 1, 1,
        '2026-12-05 20:00+03', '2026-12-05 22:30+03', 12, 'on_sale',
        'Балкон на этот концерт закрыт'),
    ('Спектакль «Чайка»', 2, 3, 2,
        '2026-10-25 19:00+03', '2026-10-25 22:00+03', 16, 'on_sale',
        'Комедия в четырёх действиях по пьесе А. П. Чехова'),
    ('Новогодняя сказка «Морозко»', 4, 3, 2,
        '2026-12-28 12:00+03', '2026-12-28 13:15+03',  0, 'announced',
        NULL),
    ('Стендап: открытый микрофон', 3, 2, 3,
        '2026-11-07 20:00+03', '2026-11-07 22:00+03', 18, 'on_sale',
        NULL),
    ('Джаз в Котельной', 1, 2, 3,
        '2026-09-12 21:00+03', '2026-09-12 23:30+03', 18, 'finished',
        'Прошедшее мероприятие'),
    ('Новогодний бал', 1, 1, 1,
        '2026-12-31 22:00+03', '2027-01-01 03:00+03', 16, 'cancelled',
        'Отменено организатором'),
    ('Лекция о театре XX века', NULL, 3, 2,
        '2026-11-20 18:30+03', '2026-11-20 20:00+03', 12, 'announced',
        'Категория пока не назначена');


INSERT INTO event_prices (event_id, sector_id, price) VALUES
    (1, 1, 3500.00), (1, 2, 2500.00), (1, 3, 1500.00),
    (2, 1, 4000.00), (2, 2, 3000.00),
    (3, 4, 2800.00), (3, 5, 2000.00), (3, 6, 5000.00),
    (4, 4,  900.00), (4, 5,  700.00),
    (5, 7, 1200.00), (5, 8, 1800.00),
    (6, 7, 1500.00), (6, 8, 2200.00),
    (7, 1, 6000.00), (7, 2, 4500.00), (7, 3, 3000.00);


INSERT INTO customers (last_name, first_name, middle_name, email, phone, registered_at) VALUES
    ('Петров',   'Иван',    'Сергеевич',  'ivan.petrov@example.com',   '+79161234567', '2026-03-12 10:15+03'),
    ('Смирнова', 'Анна',    'Викторовна', 'anna.smirnova@example.org', '+79031112233', '2026-05-02 19:40+03'),
    ('Козлов',   'Дмитрий', NULL,         'd.kozlov@example.net',      NULL,           '2026-06-20 08:05+03'),
    ('Волкова',  'Мария',   'Игоревна',   'm.volkova@example.com',     '+79265554433', '2026-07-01 13:30+03'),
    ('Новиков',  'Сергей',  'Павлович',   's.novikov@example.org',     NULL,           '2026-08-15 21:00+03'),
    ('Морозова', 'Ольга',   NULL,         'olga.morozova@example.net', '+79817778899', '2026-08-28 16:45+03'),
    ('Лебедев',  'Никита',  'Олегович',   'n.lebedev@example.com',     '+79500001122', '2026-09-30 12:00+03');


INSERT INTO orders (customer_id, created_at, status, paid_at) VALUES
    (1, '2026-10-01 12:00+03', 'paid',      '2026-10-01 12:04+03'),
    (2, '2026-10-02 18:30+03', 'paid',      '2026-10-02 18:31+03'),
    (3, '2026-10-03 09:15+03', 'paid',      '2026-10-03 09:20+03'),
    (1, '2026-10-04 20:00+03', 'paid',      '2026-10-04 20:02+03'),
    (4, '2026-10-05 14:00+03', 'new',       NULL),
    (5, '2026-10-05 16:00+03', 'cancelled', NULL),
    (6, '2026-09-01 10:00+03', 'paid',      '2026-09-01 10:03+03'),
    (2, '2026-10-05 11:00+03', 'paid',      '2026-10-05 11:00+03');


INSERT INTO tickets (order_id, event_id, sector_id, row_no, seat_no, price) VALUES
    (1, 1, 1, 3,  5, 3500.00),
    (1, 1, 1, 3,  6, 3500.00),
    (2, 3, 6, 1,  1, 5000.00),
    (2, 3, 6, 1,  2, 5000.00),
    (3, 5, 7, 1,  1, 1200.00),
    (3, 5, 7, 1,  2, 1200.00),
    (3, 5, 7, 1,  3, 1200.00),
    (4, 2, 1, 1,  1, 4000.00),
    (4, 2, 1, 1,  2, 4000.00),
    (4, 2, 1, 3,  5, 4000.00),
    (4, 3, 4, 2,  3, 2800.00),
    (5, 1, 2, 2,  4, 2500.00),
    (7, 6, 7, 1, 10, 1500.00),
    (7, 6, 8, 1,  1, 1980.00),
    (8, 1, 1, 3,  7,    0.00);


SELECT 'categories'   AS table_name, count(*) AS rows FROM categories
UNION ALL SELECT 'organizers',   count(*) FROM organizers
UNION ALL SELECT 'venues',       count(*) FROM venues
UNION ALL SELECT 'sectors',      count(*) FROM sectors
UNION ALL SELECT 'seats',        count(*) FROM seats
UNION ALL SELECT 'events',       count(*) FROM events
UNION ALL SELECT 'event_prices', count(*) FROM event_prices
UNION ALL SELECT 'customers',    count(*) FROM customers
UNION ALL SELECT 'orders',       count(*) FROM orders
UNION ALL SELECT 'tickets',      count(*) FROM tickets;

SELECT o.id                         AS order_id,
       c.last_name || ' ' || c.first_name AS customer,
       o.status,
       count(t.id)                  AS tickets,
       coalesce(sum(t.price), 0.00) AS total
FROM orders o
JOIN customers c   ON c.id = o.customer_id
LEFT JOIN tickets t ON t.order_id = o.id
GROUP BY o.id, c.last_name, c.first_name, o.status
ORDER BY o.id;
