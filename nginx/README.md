# Nginx HTTP Server with Proxy and Caching

## Project Structure

```
project-root/
├── docker-compose.yml
├── examples/
│   └── test-slow-endpoint.sh    # Test script for 499 response code
├── nginx/
│   └── nginx.conf               # Nginx configuration
└── upstream/
    ├── Dockerfile.ruby          # Ruby service Dockerfile
    └── slow-ruby-service.rb     # Slow Ruby service implementation
```

## Quick Start

### 1. Start the Services

From the `nginx/` directory, start all services:

```bash
docker-compose up -d
```

This will start:
- **Nginx server** on port 8083 (HTTP)
- **Slow Ruby service** on port 8081

### 3. Verify Services are Running

Check that all containers are running:

```bash
docker-compose ps
```

You should see both `nginx` and `slow-ruby-service` containers in the "Up" state.

## Available Endpoints

### HTTP Server (Port 8083)

| Endpoint | Description | Expected Response |
|----------|-------------|-------------------|
| `/` | Welcome message | "Welcome to nginx server" |
| `/slow-process` | Proxies to Ruby service | Response from slow-ruby-service |
| `/cached-endpoint` | **Proxies to Ruby service with caching** | **Cached response from slow-ruby-service** |
| `/slow-body-response` | Rate-limited slow response | Slow response (100 bytes/sec) |
| `/test_444` | Test 444 status code | 444 (No Response) |



## Testing the Service

### Basic HTTP Testing

Test the basic HTTP endpoints:

```bash
# Test welcome endpoint
curl http://localhost:8083/

# Test 444 response
curl -i http://localhost:8083/test_444

# Test slow endpoint (will take time due to rate limiting)
curl http://localhost:8083/slow-body-response
```

### Testing Slow Endpoint (499 Response Code)

Use the provided test script to test for 499 response codes:

```bash
cd nginx/examples
chmod +x test-slow-endpoint.sh
./test-slow-endpoint.sh
```

This script:
1. Sends a request to `/slow-process` endpoint
2. Waits for processing to start
3. Kills the curl process to simulate client disconnection
4. Checks for 499 status codes in nginx logs



### Testing Slow Ruby Service

Test the upstream Ruby service directly:

```bash
curl http://localhost:8081/
```

### Monitoring and Debugging

#### View Container Logs

```bash
# View nginx logs
docker-compose logs nginx

# View Ruby service logs
docker-compose logs slow-ruby-service

# Follow logs in real-time
docker-compose logs -f nginx
```

#### Check Container Status

```bash
# Check running containers
docker-compose ps

# Check container resource usage
docker stats
```

#### Access Container Shell

```bash
# Access nginx container
docker-compose exec nginx sh

# Access Ruby service container
docker-compose exec slow-ruby-service sh
```



## Proxy Caching

The `/cached-endpoint` demonstrates nginx's proxy caching capabilities:

### Cache Configuration

- **Cache Path**: `/var/cache/nginx` (persisted via Docker volume)
- **Cache Zone**: `my_cache` with 10MB memory allocation
- **Cache Size**: Maximum 10GB on disk
- **Cache Duration**: 10 minutes for successful responses, 1 minute for 404s
- **Cache Lock**: Prevents multiple requests from updating the same cache entry

### Cache Headers

Responses include cache-related headers:
- `X-Cache-Status`: Shows cache status (HIT, MISS, UPDATING, etc.)
- `X-Cache-Key`: Shows the cache key used

### Testing Cache Behavior

```bash
# First request - should be a MISS and take 5 seconds
time curl http://localhost:8083/cached-endpoint

# Second request - should be a HIT and be instant
time curl http://localhost:8083/cached-endpoint

# Check cache headers
curl -i http://localhost:8083/cached-endpoint | grep X-Cache
```

### Cache Invalidation

To clear the cache, restart the nginx container:
```bash
docker-compose restart nginx
```

## Stopping the Services

To stop all services:

```bash
docker-compose down
```

To stop and remove all containers, networks, and volumes:

```bash
docker-compose down -v
```

## Troubleshooting

### Common Issues

1. **Port already in use**: Ensure ports 8083 and 8081 are available
2. **Container won't start**: Check logs with `docker-compose logs`

### Reset Everything

If you need to start fresh:

```bash
# Stop and remove everything
docker-compose down -v

# Remove any existing images
docker-compose down --rmi all

# Start fresh
docker-compose up -d
```