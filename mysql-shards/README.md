# MySQL Sharding with ProxySQL

This project demonstrates a MySQL sharding setup using ProxySQL as a query router. The setup includes three MySQL shards and a ProxySQL instance that routes queries based on user ID patterns.

## Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Shard 0   │    │   Shard 1   │    │   Shard 2   │
│  (Port 3307)│    │  (Port 3308)│    │  (Port 3309)│
└─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │
       └───────────────────┼───────────────────┘
                           │
                   ┌─────────────┐
                   │  ProxySQL   │
                   │ (Port 6033) │
                   └─────────────┘
                           │
                   ┌─────────────┐
                   │   Client    │
                   └─────────────┘
```

## Components

- **3 MySQL Shards**: Running on ports 3307, 3308, and 3309
- **ProxySQL**: Query router running on port 6033 (MySQL) and 6032 (Admin)
- **Sharding Strategy**: Based on user ID modulo 3

## Quick Start

### 1. Start the Services

```bash
docker-compose up -d
```

This will start:
- 3 MySQL shards (shard0, shard1, shard2)
- 1 ProxySQL instance

### 2. Wait for Services to be Ready

```bash
docker-compose ps
```

Ensure all services show as "running" status.

### 3. Configure ProxySQL

Connect to ProxySQL admin interface:

```bash
mysql -u myadmin -pmyadminpass -h127.0.0.1 -P6032
```

Apply the configuration:

```sql
LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;

LOAD MYSQL QUERY RULES TO RUNTIME;
SAVE MYSQL QUERY RULES TO DISK;
```

### 4. Set Up Database Access

For each shard, create the necessary user:

```bash
# Connect to each shard
mysql -u root -proot -h127.0.0.1 -P3307
mysql -u root -proot -h127.0.0.1 -P3308
mysql -u root -proot -h127.0.0.1 -P3309
```

In each MySQL instance, run:

```sql
CREATE USER 'shard_user'@'%' IDENTIFIED BY 'root';
GRANT ALL PRIVILEGES ON *.* TO 'shard_user'@'%';
GRANT SELECT ON *.* TO 'shard_user'@'%';
FLUSH PRIVILEGES;
```

### 5. Create Schema and Tables

Connect to ProxySQL (which will route to the appropriate shard):

```bash
mysql -u shard_user -proot -h127.0.0.1 -P6033
```

Create the database schema:

```sql
USE demo;

CREATE TABLE IF NOT EXISTS `users` (
  id INT PRIMARY KEY,
  name VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS `orders` (
  id INT PRIMARY KEY,
  user_id INT,
  amount DECIMAL(10,2)
);
```

### 6. Insert Sample Data

```sql
USE demo;

INSERT INTO users VALUES (1,'Alice'),(2,'Bob'),(3,'Carol');
INSERT INTO orders VALUES (1,1,100.00),(2,2,150.00),(3,3,200.00);
```

## Sharding Rules

The ProxySQL configuration routes queries based on user ID patterns:

- **Shard 0**: User IDs where `id % 3 = 0`
- **Shard 1**: User IDs where `id % 3 = 1`  
- **Shard 2**: User IDs where `id % 3 = 2`

### Example Queries

```sql
-- These queries will be routed to different shards based on user ID
SELECT * FROM users WHERE id = 1;  -- Routes to Shard 1 (1 % 3 = 1)
SELECT * FROM users WHERE id = 2;  -- Routes to Shard 2 (2 % 3 = 2)
SELECT * FROM users WHERE id = 3;  -- Routes to Shard 0 (3 % 3 = 0)
```

## Configuration Details

### ProxySQL Configuration (`proxysql.cnf`)

- **Admin Interface**: Port 6032 (admin:admin, myadmin:myadminpass)
- **MySQL Interface**: Port 6033
- **Backend Servers**: 3 MySQL shards in different hostgroups
- **Query Rules**: Pattern-based routing for user queries

### Docker Services

- **shard0**: MySQL 8.0 on port 3307
- **shard1**: MySQL 8.0 on port 3308  
- **shard2**: MySQL 8.0 on port 3309
- **proxysql**: ProxySQL 3.0.1 with admin port 6032 and MySQL port 6033

## Monitoring and Management

### Check ProxySQL Status

```bash
mysql -u myadmin -pmyadminpass -h127.0.0.1 -P6032 -e "SELECT * FROM mysql_servers;"
```

### View Query Rules

```bash
mysql -u myadmin -pmyadminpass -h127.0.0.1 -P6032 -e "SELECT * FROM mysql_query_rules;"
```

### Monitor Query Statistics

```bash
mysql -u myadmin -pmyadminpass -h127.0.0.1 -P6032 -e "SELECT * FROM stats_mysql_query_digest;"
```

## Troubleshooting

### Common Issues

1. **Connection Refused**: Ensure all Docker containers are running
2. **Authentication Errors**: Verify user creation on all shards
3. **Query Routing Issues**: Check ProxySQL query rules configuration

### Logs

```bash
# View ProxySQL logs
docker-compose logs proxysql

# View specific shard logs
docker-compose logs shard0
docker-compose logs shard1
docker-compose logs shard2
```

## Cleanup

To stop and remove all containers and volumes:

```bash
docker-compose down -v
```

## Ports Summary

| Service | Port | Purpose |
|---------|------|---------|
| shard0 | 3307 | MySQL Shard 0 |
| shard1 | 3308 | MySQL Shard 1 |
| shard2 | 3309 | MySQL Shard 2 |
| proxysql | 6032 | ProxySQL Admin |
| proxysql | 6033 | ProxySQL MySQL |

## Security Notes

- Default passwords are used for demonstration purposes
- In production, use strong passwords and proper security measures
- Consider using SSL/TLS for database connections
- Implement proper firewall rules and network segmentation
