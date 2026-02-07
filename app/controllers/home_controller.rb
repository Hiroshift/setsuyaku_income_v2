class HomeController < ApplicationController
  include TimeFormatting
  before_action :authenticate_user!, only: [:create, :suggest, :welcome]

  def index
    today = Date.today

    if user_signed_in?
      recordings = current_user.recordings

      # --- 今日 ---
      @today_income = recordings.where(recorded_date: today).sum(:amount)
      @total_minutes = calculate_minutes(@today_income)
      @virtual_work_time = format_time(@total_minutes)

      # --- 昨日 ---
      yesterday = today - 1
      @yesterday_income = recordings.where(recorded_date: yesterday).sum(:amount)
      @yesterday_recorded = @yesterday_income > 0

      # --- 連続記録 ---
      @streak = calculate_streak(recordings, today)

      # --- 今週のサマリー ---
      week_start = today.beginning_of_week(:monday)
      @week_income = recordings.where(recorded_date: week_start..today).sum(:amount)
      @week_minutes = calculate_minutes(@week_income)
      @week_time = format_time(@week_minutes)

      last_week_start = week_start - 7
      last_week_end = week_start - 1
      @last_week_income = recordings.where(recorded_date: last_week_start..last_week_end).sum(:amount)

      # --- 累計 ---
      @total_income = recordings.sum(:amount)
      @lifetime_minutes = calculate_minutes(@total_income)
      @lifetime_display = format_life_time(@lifetime_minutes)

      # --- 年間プロジェクション ---
      first_record = recordings.minimum(:recorded_date)
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
    recorded_date = parse_date(params[:recorded_date])
    note = params[:note].presence&.strip

    if amount.positive?
      if current_user.recordings.create(amount: amount, recorded_date: recorded_date, note: note)
        message = "¥#{amount.to_fs(:delimited)}の節約収入"
        if current_user.hourly_rate.positive?
          minutes = (amount.to_f / current_user.hourly_rate * 60).round
          message += " ＝ #{format_time(minutes)}ぶんの労働"
        end
        message += "（#{note}）" if note.present?
        flash[:notice] = message
      else
        flash[:alert] = '記録に失敗しました。もう一度お試しください。'
      end
    else
      flash[:alert] = '節約金額を正しく入力してください。'
    end
    redirect_to root_path
  end

  # 初回登録後のウェルカム画面
  def welcome
    @nickname = current_user.nickname
    @hourly_rate = current_user.hourly_rate

    if @hourly_rate.positive?
      # 3段階の換算例を計算
      @examples = [100, 500, 1000].map do |amount|
        minutes = (amount.to_f / @hourly_rate * 60).round
        { amount: amount, time: format_time(minutes) }
      end
    else
      @examples = []
    end
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

  def calculate_streak(recordings, today)
    # 今日の記録がなければ昨日から数える
    check_date = recordings.where(recorded_date: today).exists? ? today : today - 1
    streak = 0

    loop do
      if recordings.where(recorded_date: check_date).exists?
        streak += 1
        check_date -= 1
      else
        break
      end
    end

    streak
  end

  def parse_date(date_str)
    date = Date.parse(date_str) rescue nil
    # 未来の日付や7日以上前は許可しない
    if date && date <= Date.today && date >= 7.days.ago.to_date
      date
    else
      Date.today
    end
  end
end
