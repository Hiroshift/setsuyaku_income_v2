class ApplicationController < ActionController::Base
  before_action :basic_auth
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def basic_auth
    return if Rails.env.test?

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER_SETSUYAKU'] && password == ENV['BASIC_AUTH_PASSWORD_SETSUYAKU']
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :hourly_rate])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :hourly_rate])
  end
end
