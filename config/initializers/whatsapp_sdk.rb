WhatsappSdk.configure do |config|
  config.access_token = Rails.application.credentials.dig(:whatsapp, :access_token)
  config.logger = Logger.new(STDOUT) # optional, Faraday logger to attach
  config.logger_options = { bodies: true } # optional, they are all valid logger_options for Faraday
end
