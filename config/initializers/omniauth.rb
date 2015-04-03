Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, "434707570036416", "1d2b3386433bc284d7dd3915f9a966f8",
      :scope => 'email,user_birthday,read_stream,adaccounts', :display => 'popup'
end
