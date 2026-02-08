class ApplicationController < ActionController::Base
  before_action :basic_auth
  before_action :configure_permitted_parameters, if: :devise_controller?

  private

  def basic_auth
    return if Rails.env.test?

    # ヘルスチェック用エンドポイントはBasic認証をスキップ（UptimeRobot等の監視用）
    return if controller_name == 'health'

    # PWAスタンドアロンモードからのアクセスはBasic認証をスキップ
    # （Deviseのログイン認証で保護される）
    return if pwa_standalone_request?

    authenticate_or_request_with_http_basic do |username, password|
      username == ENV['BASIC_AUTH_USER_SETSUYAKU'] && password == ENV['BASIC_AUTH_PASSWORD_SETSUYAKU']
    end
  end

  def pwa_standalone_request?
    # セッションにPWAフラグがあればスキップ
    return true if session[:pwa_standalone]

    # PWA判定用パラメータ（manifest.webmanifestのstart_urlから付与）
    if params[:mode] == 'standalone'
      session[:pwa_standalone] = true
      return true
    end

    false
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nickname, :hourly_rate])
    devise_parameter_sanitizer.permit(:account_update, keys: [:nickname, :hourly_rate])
  end
end
