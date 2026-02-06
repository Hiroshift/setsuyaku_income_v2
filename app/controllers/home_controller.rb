class HomeController < ApplicationController
  include TimeFormatting
  before_action :authenticate_user!, only: [:create, :suggest]

  def index
    today = Date.today

    if user_signed_in?
      # --- 今日 ---
      @today_income = current_user.recordings.where(recorded_date: today).sum(:amount)
      @total_minutes = calculate_minutes(@today_income)
      @virtual_work_time = format_time(@total_minutes)

      # --- 累計 ---
      @total_income = current_user.recordings.sum(:amount)
      @lifetime_minutes = calculate_minutes(@total_income)
      @lifetime_display = format_life_time(@lifetime_minutes)

      # --- 年間プロジェクション ---
      first_record = current_user.recordings.minimum(:recorded_date)
      if first_record && @total_income > 0
        days_active = [(today - first_record).to_i, 1].max
        daily_avg_income = @total_income.to_f / days_active
        remaining_days = (Date.new(today.year, 12, 31) - today).to_i
        projected_annual_income = @total_income + (daily_avg_income * remaining_days).round
        projected_annual_minutes = calculate_minutes(projected_annual_income)
        @annual_projection = format_life_time(projected_annual_minutes)
        @daily_avg_display = "¥#{daily_avg_income.round.to_fs(:delimited)}/日"
      end
    else
      @today_income = 0
      @virtual_work_time = "0分"
      @total_income = 0
      @total_minutes = 0
      @lifetime_minutes = 0
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
end
