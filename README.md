# Базы данных — лабораторные работы

PostgreSQL 17, сервер запускается в Docker.

| № | Тема | Папка | Срок |
|---|------|-------|------|
| 1 | Проектирование и реализация реляционной БД — вариант 12, продажа билетов на мероприятия | [lab1](lab1/) | 20.10 |

## Сервер PostgreSQL

```bash
docker compose up -d                                # запустить (первый раз скачает образ postgres:17)
docker compose ps                                   # статус: должно быть "healthy"
docker compose exec pg psql -U postgres -d labs     # консоль psql
docker compose stop                                 # остановить, данные сохранятся
```

Корень репозитория смонтирован в контейнер как `/labs`, скрипты лаб запускаются по этому пути:

```bash
docker compose exec pg psql -U postgres -d labs -f /labs/lab1/schema.sql
```

Подключение из DBeaver / pgAdmin / DataGrip:

| Параметр | Значение |
|---|---|
| Host | `localhost` |
| Port | `5432` |
| Database | `labs` |
| User / Password | `postgres` / `postgres` |

## Структура

```
.
├── docker-compose.yml   — сервер PostgreSQL 17
├── labN/
│   ├── README.md        — задание, файлы, запуск
│   └── *.sql            — скрипты лабы
└── sources/             — PDF с заданиями (только локально, в git не входит)
```
