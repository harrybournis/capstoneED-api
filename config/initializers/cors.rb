# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to accept cross-origin Ajax requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'http://127.0.0.1:8085', 'http://localhost:8085' 

    resource '*',
      headers: :any,
      expose: 'XSRF-TOKEN',
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end

  allow do
    origins 'http://localhost:8090', 'http://127.0.0.1:8090'

    resource '*',
      headers: :any,
      expose: 'XSRF-TOKEN',
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end

  allow do
    origins 'http://localhost:4500', 'http://127.0.0.1:4500'

    resource '*',
      headers: :any,
      expose: 'XSRF-TOKEN',
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      credentials: true
  end

end
