#!/bin/bash

echo "Testing for 499 response code (Client Closed Request)..."

echo "Starting curl request to /slow-process endpoint..."
echo "This endpoint will take time to process due to proxy_pass to non-existent backend..."

# Send request to slow-process endpoint and capture the process ID
curl -i http://localhost:8083/slow-process > /tmp/curl_output 2>&1 &
CURL_PID=$!

echo "Curl process started with PID: $CURL_PID"
echo "Waiting 2 seconds for the request to start processing..."

sleep 2

echo "Killing curl process to simulate client disconnection..."
kill $CURL_PID 2>/dev/null

echo "Waiting for nginx to process the disconnection..."
sleep 2

echo "Checking nginx access logs for 499 response..."
echo "You should see a 499 status code in the nginx logs if the test was successful."

echo ""
echo "Test completed!"
echo ""
echo "Note: Check your nginx container logs with: docker logs <container-name>"
echo "Look for a log entry with status 499 for the /slow-process endpoint request."
echo ""
echo "The /slow-process endpoint should generate 499 responses because:"
echo "1. It tries to proxy to a non-existent backend (127.0.0.1:9999)"
echo "2. This keeps nginx in 'processing' state, not 'transferring' state"
echo "3. When client disconnects during processing, nginx logs it as 499"
