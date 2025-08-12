# Nginx with SSL and Client Certificate Verification

## Project Structure

```
project-root/
├── docker-compose.yml
├── examples/
│   └── test-slow-endpoint.sh    # Test script for 499 response code
├── nginx/
│   ├── nginx.conf
│   └── ssl/
│       ├── generate-certs.sh    # Script to generate SSL certificates
│       ├── ca.crt              # CA certificate for client verification
│       ├── ca.key              # CA private key
│       ├── server.crt          # Server certificate
│       └── server.key          # Server private key
└── upstream/
    ├── Dockerfile.ruby          # Ruby service Dockerfile
    └── slow-ruby-service.rb     # Slow Ruby service implementation
```

## Quick Start

### 1. Generate SSL Certificates

First, generate the required SSL certificates:

```bash
cd nginx/nginx/ssl
./generate-certs.sh
```

### 2. Start the Services

From the `nginx/` directory, start all services:

```bash
docker-compose up -d
```

This will start:
- **Nginx server** on ports 8083 (HTTP) and 8443 (HTTPS)
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
| `/slow` | Rate-limited slow response | Slow response (1 byte/sec) |
| `/test_444` | Test 444 status code | 444 (No Response) |

### HTTPS Server (Port 8443)

| Endpoint | Description | Expected Response |
|----------|-------------|-------------------|
| `/` | Welcome message | "Welcome to nginx HTTPS server" |
| `/test_495` | SSL client cert test | "SSL test" (requires valid client cert) |

## Testing the Service

### Basic HTTP Testing

Test the basic HTTP endpoints:

```bash
# Test welcome endpoint
curl http://localhost:8083/

# Test 444 response
curl -i http://localhost:8083/test_444

# Test slow endpoint (will take time due to rate limiting)
curl http://localhost:8083/slow
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

### Testing SSL with Client Certificates

To test the HTTPS endpoints with client certificate verification:

```bash
# Test without client certificate (should fail)
curl -k https://localhost:8443/

# Test with client certificate (if you have one)
curl -k --cert client.crt --key client.key https://localhost:8443/
```

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

## SSL Certificates

This setup includes both server SSL certificates and client certificate verification. The certificates are self-signed for development/testing purposes.

### Quick Setup

To generate all required SSL certificates, run the provided script:

```bash
cd nginx/nginx/ssl
./generate-certs.sh
```

### Manual Generation

If you prefer to generate certificates manually, follow these steps:

#### 1. Generate CA Certificate (for client verification)

```bash
# Generate CA private key
openssl genrsa -out ca.key 2048

# Generate CA certificate
openssl req -new -x509 -days 365 -key ca.key -out ca.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=CA"
```

#### 2. Generate Server Certificate

```bash
# Generate server private key
openssl genrsa -out server.key 2048

# Generate server certificate signing request
openssl req -new -key server.key -out server.csr \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=localhost"

# Sign server certificate with CA
openssl x509 -req -in server.csr -CA ca.crt -CAkey ca.key \
    -CAcreateserial -out server.crt -days 365

# Clean up temporary files
rm server.csr
```

### Certificate Files

- **ca.crt**: CA certificate used to verify client certificates
- **ca.key**: CA private key (keep secure)
- **server.crt**: Server certificate for HTTPS
- **server.key**: Server private key (keep secure)
- **ca.srl**: CA serial number file (auto-generated)

### Configuration

The nginx configuration includes:
- HTTP server on port 8080 (mapped to 8083 externally)
- HTTPS server on port 443 (mapped to 8443 externally) with client certificate verification
- Root path handlers for both HTTP and HTTPS
- SSL client certificate verification enabled (`ssl_verify_client on`)
- Upstream proxy to slow-ruby-service
- Rate limiting on `/slow` endpoint

### Security Notes

⚠️ **Important**: These are self-signed certificates for development/testing only. For production use:
- Obtain certificates from a trusted Certificate Authority
- Keep private keys secure and never commit them to version control
- Consider using Let's Encrypt for free, trusted certificates

### Regenerating Certificates

To regenerate certificates (e.g., when they expire):
1. Delete existing certificate files: `rm -f *.crt *.key *.srl`
2. Run the generation script: `./generate-certs.sh`
3. Restart the nginx container: `docker-compose restart`

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

1. **Port already in use**: Ensure ports 8083, 8443, and 8081 are available
2. **SSL certificate errors**: Regenerate certificates using `./generate-certs.sh`
3. **Container won't start**: Check logs with `docker-compose logs`
4. **Permission denied**: Ensure the SSL script is executable: `chmod +x generate-certs.sh`

### Reset Everything

If you need to start fresh:

```bash
# Stop and remove everything
docker-compose down -v

# Remove any existing images
docker-compose down --rmi all

# Regenerate certificates
cd nginx/ssl && ./generate-certs.sh

# Start fresh
docker-compose up -d
```