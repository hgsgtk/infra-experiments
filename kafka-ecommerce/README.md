# Kafka E-commerce Infrastructure

A Docker-based Kafka setup for e-commerce event streaming with pre-configured topics for orders, payments, and inventory management.

## Overview

This project provides a complete Kafka infrastructure setup for an e-commerce system, including:
- **Apache Kafka** - Distributed streaming platform
- **Apache Zookeeper** - Coordination service for Kafka
- **Pre-configured topics** for e-commerce events
- **Topic initialization script** for easy setup

## Prerequisites

- Docker and Docker Compose installed on your system
- At least 4GB of available memory for the containers

## Quick Start

1. **Clone and navigate to the project:**
   ```bash
   cd kafka-ecommerce
   ```

2. **Start the Kafka infrastructure:**
   ```bash
   docker compose up -d
   ```

3. **Initialize Kafka topics:**
   ```bash
   chmod +x kafka-topics-init.sh
   docker compose exec kafka bash /kafka-topics-init.sh
   ```

4. **Verify topics are created:**
   ```bash
   docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --list
   ```

## Topics Configuration

The system comes with three pre-configured topics optimized for e-commerce workloads:

| Topic | Partitions | Purpose |
|-------|------------|---------|
| `orders` | 6 | Order processing and fulfillment events |
| `payments` | 3 | Payment processing and transaction events |
| `inventory` | 4 | Inventory updates and stock management |

## Usage Examples

### Producing Messages

```bash
# Connect to Kafka container
docker compose exec kafka bash

# Produce messages to orders topic
kafka-console-producer --broker-list localhost:9092 --topic orders
```

### Consuming Messages

```bash
# Consume messages from orders topic (from beginning)
kafka-console-consumer --bootstrap-server localhost:9092 --topic orders --from-beginning

# Consume messages from orders topic (latest messages only)
kafka-console-consumer --bootstrap-server localhost:9092 --topic orders
```

### Working with Different Topics

```bash
# Produce to payments topic
kafka-console-producer --broker-list localhost:9092 --topic payments

# Consume from inventory topic
kafka-console-consumer --bootstrap-server localhost:9092 --topic inventory --from-beginning
```

## Configuration

### Kafka Configuration
- **Bootstrap Server**: `localhost:9092`
- **Replication Factor**: 1 (single broker setup)
- **Zookeeper**: `localhost:2181`

### Docker Services
- **Kafka**: Port 9092 (external), 9093 (internal)
- **Zookeeper**: Port 2181

## Management Commands

### Start Services
```bash
docker compose up -d
```

### Stop Services
```bash
docker compose down
```

### View Logs
```bash
# All services
docker compose logs

# Specific service
docker compose logs kafka
docker compose logs zookeeper
```

### Access Kafka Shell
```bash
docker compose exec kafka bash
```

## Topic Management

### List All Topics
```bash
docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --list
```

### Describe Topic Details
```bash
docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --describe --topic orders
```

### Delete Topic (if needed)
```bash
docker compose exec kafka kafka-topics --bootstrap-server localhost:9092 --delete --topic topic-name
```

## Development Workflow

1. **Start the infrastructure** when beginning development
2. **Initialize topics** if starting fresh
3. **Produce/consume messages** for testing your applications
4. **Stop services** when done to free up resources

## Troubleshooting

### Common Issues

**Topic creation fails:**
- Ensure Zookeeper is running: `docker compose logs zookeeper`
- Wait a few seconds after starting services before creating topics

**Cannot connect to Kafka:**
- Verify services are running: `docker compose ps`
- Check if port 9092 is available on your system

**Messages not appearing:**
- Ensure you're using the correct topic name
- Check if you're consuming from the right offset (`--from-beginning` vs latest)

### Useful Debug Commands

```bash
# Check container status
docker compose ps

# View real-time logs
docker compose logs -f

# Check Kafka cluster health
docker compose exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092
```

## Cleanup

To completely remove all data and start fresh:

```bash
# Stop and remove containers, networks, and volumes
docker compose down -v

# Remove any remaining data
docker system prune -f
```

## Next Steps

This infrastructure is ready for:
- Building e-commerce microservices
- Implementing event-driven architectures
- Setting up real-time data pipelines
- Developing order processing workflows

Consider extending this setup with:
- Schema Registry for message validation
- Kafka Connect for data integration
- Monitoring tools (Prometheus, Grafana)
- Multiple Kafka brokers for production use 