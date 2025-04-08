OpenAI.configure do |config|
  config.access_token = Rails.application.credentials.openai_key
  config.log_errors = true
end
