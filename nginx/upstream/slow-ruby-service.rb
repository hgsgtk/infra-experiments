#!/usr/bin/env ruby

require 'socket'
require 'json'

class SlowRubyService
  def initialize(port = 8081)
    @port = port
    @server = TCPServer.new('0.0.0.0', @port)
    puts "Slow Ruby Service listening on port #{@port}"
  end

  def start
    loop do
      client = @server.accept
      Thread.new { handle_request(client) }
    end
  rescue Interrupt
    puts "\nShutting down Slow Ruby Service..."
    @server.close
  end

  private

  def handle_request(client)
    request_line = client.gets
    return unless request_line

    method, path, version = request_line.split(' ')
    
    # Read headers
    headers = {}
    while (line = client.gets.strip) && !line.empty?
      key, value = line.split(': ', 2)
      headers[key.downcase] = value if key && value
    end

    # Read body if present
    body = ""
    if headers['content-length']
      body = client.read(headers['content-length'].to_i)
    end

    puts "Received #{method} request to #{path}"
    puts "Headers: #{headers.inspect}"
    puts "Body: #{body}" unless body.empty?

    # Simulate slow processing
    sleep_time = case path
                 when '/slow-process'
                   5  # 5 seconds delay
                 when '/slow-api'
                   3  # 3 seconds delay
                 else
                   1  # 1 second default delay
                 end

    puts "Processing request for #{sleep_time} seconds..."
    sleep(sleep_time)

    # Send response
    response_body = {
      message: "Request processed successfully",
      path: path,
      method: method,
      processing_time: sleep_time,
      timestamp: Time.now.iso8601,
      headers_received: headers.keys
    }.to_json

    response = [
      "HTTP/1.1 200 OK",
      "Content-Type: application/json",
      "Content-Length: #{response_body.bytesize}",
      "Cache-Control: no-cache, no-store, must-revalidate",
      "Pragma: no-cache",
      "Expires: 0",
      "",
      response_body
    ].join("\r\n")

    client.write(response)
    client.close
    puts "Response sent for #{path}"
  end
end

if __FILE__ == $0
  service = SlowRubyService.new
  service.start
end
