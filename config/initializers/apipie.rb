Apipie.configure do |config|
  config.app_name                = "Capstoned API"
  config.api_base_url            = ""
  config.doc_base_url            = "/apipie"
  # where is your API defined?
  config.api_controllers_matcher = "#{Rails.root}/app/controllers/v1/*.rb"
  config.validate = false
end
