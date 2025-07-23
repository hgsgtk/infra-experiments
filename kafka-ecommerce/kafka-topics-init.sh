#!/bin/bash

# Define topics and their partition counts for an e-commerce system
TOPICS=("orders:6" "payments:3" "inventory:4")

for topic in "${TOPICS[@]}"
do
  NAME="${topic%%:*}"
  PARTITIONS="${topic##*:}"
  kafka-topics --create \
    --if-not-exists \
    --bootstrap-server localhost:9092 \
    --replication-factor 1 \
    --partitions $PARTITIONS \
    --topic $NAME
done
