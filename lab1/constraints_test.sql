-- проверка ограничений


\echo
\echo '===== Часть 1. Неправильные запросы, на каждый база должна выдать ошибку ====='


\echo
\echo '1. NOT NULL: добавляю покупателя без email, а email обязательный'
INSERT INTO customers (last_name, first_name)
VALUES ('Пупкин', 'Вася');

\echo
\echo '2. UNIQUE: такой email уже есть у Петрова'
INSERT INTO customers (last_name, first_name, email)
VALUES ('Петров', 'Иван', 'ivan.petrov@example.com');

\echo
\echo '3. составной UNIQUE: место ряд 3 место 5 в партере на мероприятие 1 уже продано'
INSERT INTO tickets (order_id, event_id, sector_id, row_no, seat_no, price)
VALUES (4, 1, 1, 3, 5, 3500.00);

\echo
\echo '4. CHECK: возраст 21+, а можно только 0, 6, 12, 16 или 18'
UPDATE events SET age_limit = 21 WHERE id = 5;

\echo
\echo '5. составной CHECK: ставлю конец мероприятия раньше начала'
UPDATE events SET ends_at = starts_at - INTERVAL '1 hour' WHERE id = 1;

\echo
\echo '6. составной PRIMARY KEY: место ряд 1 место 1 в партере уже есть'
INSERT INTO seats (sector_id, row_no, seat_no)
VALUES (1, 1, 1);

\echo
\echo '7. FOREIGN KEY: мероприятие на площадке 999, а такой площадки нет'
INSERT INTO events (title, organizer_id, venue_id, starts_at, ends_at)
VALUES ('Концерт-призрак', 1, 999, '2026-12-01 19:00+03', '2026-12-01 21:00+03');

\echo
\echo '8. составной FOREIGN KEY: продаю билет в 9 ряд, а в партере всего 5 рядов'
INSERT INTO tickets (order_id, event_id, sector_id, row_no, seat_no, price)
VALUES (4, 1, 1, 9, 1, 3500.00);

\echo
\echo '9. RESTRICT: удаляю покупателя, у которого есть заказы'
DELETE FROM customers WHERE id = 1;


\echo
\echo '===== Часть 2. ON DELETE ====='
\echo 'делаю в транзакции и потом откатываю, чтобы данные не поменялись'

-- начинаю транзакцию
BEGIN;

\echo
\echo 'SET NULL: удаляю категорию Стендап, у мероприятия 5 категория станет NULL'
DELETE FROM categories WHERE name = 'Стендап';
-- было category_id = 3, стало NULL
SELECT id, title, category_id FROM events WHERE id = 5;

\echo
\echo 'CASCADE: удаляю мероприятие 7, его цены удалятся вместе с ним'
DELETE FROM events WHERE id = 7;
-- было 3 цены, стало 0
SELECT count(*) AS prices_of_event_7 FROM event_prices WHERE event_id = 7;

-- отменяю все изменения
ROLLBACK;
