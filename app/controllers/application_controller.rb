class ApplicationController < ActionController::Base
  include RecaptchaVerifiable
  protect_from_forgery with: :null_session
end
