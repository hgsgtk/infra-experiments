FROM ruby:3.2-alpine

WORKDIR /app

# Copy the Ruby service
COPY slow-ruby-service.rb .

# Make the script executable
RUN chmod +x slow-ruby-service.rb

# Expose the port
EXPOSE 8081

# Run the service
CMD ["ruby", "slow-ruby-service.rb"]
