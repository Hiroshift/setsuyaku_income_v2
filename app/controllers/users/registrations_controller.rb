class Users::RegistrationsController < Devise::RegistrationsController
  def destroy
    if current_user.destroy
      flash[:notice] = 'アカウントが削除されました。'
      redirect_to after_sign_out_path_for(:user)
    else
      flash[:alert] = 'アカウントの削除に失敗しました。もう一度お試しください。'
      redirect_to edit_user_registration_path
    end
  end

  protected

  # パスワードなしで情報を更新できるようにする
  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params)
    else
      resource.update(params)
    end
  end

  # サインアップ後のリダイレクト先を指定
  def after_sign_up_path_for(_resource)
    welcome_path # ウェルカム画面に遷移
  end

  # アカウント削除後のリダイレクト先を指定
  def after_destroy_path_for(_resource)
    root_path # ホーム画面に遷移
  end
end
