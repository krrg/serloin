Rails.application.config.middleware.use OmniAuth::Builder do
  provider :stackoverflow, '<client_id>', '<oauth secret>', :scope => 'no_expiry', :oauth_key => '<oauth key>'
end
