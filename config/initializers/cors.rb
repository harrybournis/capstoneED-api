# Be sure to restart your server when you modify this file.

# Avoid CORS issues when API is called from the frontend app.
# Handle Cross-Origin Resource Sharing (CORS) in order to
# accept cross-origin AJAX requests.

# Read more: https://github.com/cyu/rack-cors

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins 'student.capstoneed-dev.org:8080'

    resource '*',
      headers: :any,
      expose: 'XSRF-TOKEN',
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end

  allow do
    origins 'lecturer.capstoneed-dev.org:8085'

    resource '*',
      headers: :any,
      expose: 'XSRF-TOKEN',
      methods: [:get, :post, :put, :patch, :delete, :options, :head]
  end
  # allow do
  #   origins 'student.capstoneed-dev.org'

  #   resource '*',
  #     headers: :any,
  #     expose: 'XSRF-TOKEN',
  #     methods: [:get, :post, :put, :patch, :delete, :options, :head]
  # end

  # allow do
  #   origins 'lecturer.capstoneed-dev.org'

  #   resource '*',
  #     headers: :any,
  #     expose: 'XSRF-TOKEN',
  #     methods: [:get, :post, :put, :patch, :delete, :options, :head]
  # end
end
