class HomeController < ApplicationController
  before_action :authenticate_user!, only: [:create, :suggest]

  def index
    today = Date.today

    if user_signed_in?
      @today_income = current_user.recordings.where(recorded_date: today).sum(:amount)
      @total_income = current_user.recordings.sum(:amount)
      @total_minutes = calculate_minutes(@today_income)
      @virtual_work_time = format_time(@total_minutes)
    else
      @today_income = 0
      @virtual_work_time = "0分"
      @total_income = 0
      @total_minutes = 0
    end
  end

  def create
    amount = params[:amount].to_i
    if amount.positive?
      if current_user.recordings.create(amount: amount, recorded_date: Date.today)
        message = "¥#{amount.to_fs(:delimited)}の節約収入を獲得！"
        if current_user.hourly_rate.positive?
          minutes = (amount.to_f / current_user.hourly_rate * 60).round
          message += " （#{format_time(minutes)}の自由を取り戻しました）"
        end
        flash[:notice] = message
      else
        flash[:alert] = '記録に失敗しました。もう一度お試しください。'
      end
    else
      flash[:alert] = '節約金額を正しく入力してください。'
    end
    redirect_to root_path
  end

  # Turbo Frame で呼ばれる：AIに時間の使い方を聞く
  def suggest
    today_income = current_user.recordings.where(recorded_date: Date.today).sum(:amount)
    minutes = calculate_minutes(today_income)

    if minutes > 0
      @suggestion = GeminiService.suggest_time_usage(minutes: minutes, amount: today_income)
      @suggestion ||= "提案を取得できませんでした。もう一度お試しください。"
    else
      @suggestion = "まず節約を記録すると、AIが時間の使い方を提案します。"
    end

    render partial: "home/ai_result", locals: { suggestion: @suggestion, minutes: minutes }
  end

  private

  def calculate_minutes(amount)
    return 0 unless current_user.hourly_rate.positive?
    (amount.to_f / current_user.hourly_rate * 60).round
  end

  def format_time(total_minutes)
    hours = total_minutes / 60
    mins = total_minutes % 60
    if hours > 0 && mins > 0
      "#{hours}時間#{mins}分"
    elsif hours > 0
      "#{hours}時間"
    else
      "#{mins}分"
    end
  end
end
