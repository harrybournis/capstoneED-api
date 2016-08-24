Apipie.configure do |config|
  config.app_name                = "Capstoned API"
  config.api_base_url            = ""
  config.doc_base_url            = "/docs"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/docs/v1/*.rb"
  config.validate = false
end
