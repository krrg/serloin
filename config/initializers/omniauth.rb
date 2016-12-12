Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stackoverflow, ENV['CLIENT_ID'], ENV['CLIENT_SECRET'], :scope => 'no_expiry', :key => ENV['CLIENT_KEY']
end
