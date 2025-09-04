# EXPLAIN experiments in MySQL 8

This experimental project uses MySQL 8.4.6, the latest LTS version of MySQL as September 2025. [8.4.6](https://dev.mysql.com/doc/relnotes/mysql/8.4/en/news-8-4-6.html) was released on 2025-07-22.

## Quick Start

- Start the MySQL container:

```bash
docker compose up -d
```

- Connect to the MySQL server:

```bash
mysql -u root -prootpass -h 127.0.0.1 -P 3306 sampledb
```

## Run EXPLAIN/EXPLAIN ANALYZE

```sql
EXPLAIN SELECT * FROM orders WHERE user_id = 100 AND quantity > 5;

+----+-------------+--------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
| id | select_type | table  | partitions | type | possible_keys | key         | key_len | ref   | rows | filtered | Extra       |
+----+-------------+--------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
|  1 | SIMPLE      | orders | NULL       | ref  | idx_user_id   | idx_user_id | 5       | const |    1 |    33.33 | Using where |
+----+-------------+--------+------------+------+---------------+-------------+---------+-------+------+----------+-------------+
1 row in set, 1 warning (0.01 sec)
```

```sql
EXPLAIN ANALYZE SELECT * FROM orders WHERE user_id = 100 AND quantity > 5;

| -> Filter: (orders.quantity > 5)  (cost=0.283 rows=0.333) (actual time=0.045..0.045 rows=0 loops=1)
    -> Index lookup on orders using idx_user_id (user_id=100)  (cost=0.283 rows=1) (actual time=0.043..0.043 rows=0 loops=1)
```
