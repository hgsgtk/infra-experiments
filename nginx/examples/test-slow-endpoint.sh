#!/bin/bash

echo "Choose an endpoint to test for 499 response code (Client Closed Request):"
echo "1) /slow-process endpoint"
echo "2) /cached-endpoint"
echo ""
read -p "Enter your choice (1 or 2): " choice

case $choice in
    1)
        ENDPOINT="/slow-process"
        ;;
    2)
        ENDPOINT="/cached-endpoint"
        ;;
    *)
        echo "Invalid choice. Please run the script again and select 1 or 2."
        exit 1
        ;;
esac

echo ""
echo "Choose HTTP method:"
echo "1) GET (default)"
echo "2) POST"
echo "3) PUT"
echo "4) DELETE"
echo "5) Custom method"
echo ""
read -p "Enter your choice (1-5): " method_choice

case $method_choice in
    1)
        HTTP_METHOD="GET"
        ;;
    2)
        HTTP_METHOD="POST"
        ;;
    3)
        HTTP_METHOD="PUT"
        ;;
    4)
        HTTP_METHOD="DELETE"
        ;;
    5)
        read -p "Enter custom HTTP method: " HTTP_METHOD
        ;;
    *)
        echo "Invalid choice. Using GET method."
        HTTP_METHOD="GET"
        ;;
esac

echo ""
echo "Testing for 499 response code (Client Closed Request)..."
echo ""
echo "Starting curl request to $ENDPOINT endpoint using $HTTP_METHOD method..."
echo "This endpoint will take time to process due to proxy_pass to non-existent backend..."

# Send request to the selected endpoint and capture the process ID
if [ "$HTTP_METHOD" = "GET" ]; then
    curl -i -X $HTTP_METHOD http://localhost:8083$ENDPOINT > /tmp/curl_output 2>&1 &
else
    curl -i -X $HTTP_METHOD -d "test_data" http://localhost:8083$ENDPOINT > /tmp/curl_output 2>&1 &
fi
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
echo "Look for a log entry with status 499 for the $HTTP_METHOD $ENDPOINT endpoint request."
echo ""
echo "The $ENDPOINT endpoint should generate 499 responses because:"
echo "1. It tries to proxy to a non-existent backend (127.0.0.1:9999)"
echo "2. This keeps nginx in 'processing' state, not 'transferring' state"
echo "3. When client disconnects during processing, nginx logs it as 499"
