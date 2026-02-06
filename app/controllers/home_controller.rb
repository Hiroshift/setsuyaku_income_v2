class HomeController < ApplicationController
  # ログインが必要なアクションを限定
  before_action :authenticate_user!, only: [:create]

  def index
    today = Date.today

    if user_signed_in?
      # ログインしている場合の計算
      @today_income = current_user.recordings.where(recorded_date: today).sum(:amount)
      @total_income = current_user.recordings.sum(:amount)
      # 分単位で計算（例: 23分、1時間15分）
      if current_user.hourly_rate.positive?
        total_minutes = (@today_income.to_f / current_user.hourly_rate * 60).round
        hours = total_minutes / 60
        mins = total_minutes % 60
        @virtual_work_time = if hours > 0 && mins > 0
                               "#{hours}時間#{mins}分"
                             elsif hours > 0
                               "#{hours}時間"
                             else
                               "#{mins}分"
                             end
      else
        @virtual_work_time = "0分"
      end
    else
      # 未ログイン時の仮データ
      @today_income = 0
      @virtual_work_time = 0
      @total_income = 0
    end
  end

  def create
    amount = params[:amount].to_i
    if amount.positive?
      # 新しい記録をデータベースに保存
      if current_user.recordings.create(amount: amount, recorded_date: Date.today)
        # 変換情報をフラッシュメッセージに含める
        message = "¥#{amount.to_fs(:delimited)}の節約収入を獲得！"
        minutes = 0
        if current_user.hourly_rate.positive?
          minutes = (amount.to_f / current_user.hourly_rate * 60).round
          if minutes >= 60
            hours = minutes / 60
            mins = minutes % 60
            time_str = mins > 0 ? "#{hours}時間#{mins}分" : "#{hours}時間"
          else
            time_str = "#{minutes}分"
          end
          message += " （#{time_str}の自由を取り戻しました）"
        end
        flash[:notice] = message

        # Gemini AIに「取り戻した時間の使い方」を提案してもらう
        if minutes > 0
          suggestion = GeminiService.suggest_time_usage(minutes: minutes, amount: amount)
          flash[:ai_suggestion] = suggestion if suggestion.present?
        end
      else
        flash[:alert] = '記録に失敗しました。もう一度お試しください。'
      end
    else
      flash[:alert] = '節約金額を正しく入力してください。'
    end
    redirect_to root_path
  end
end
