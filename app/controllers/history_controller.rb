class HistoryController < ApplicationController
  include TimeFormatting
  before_action :authenticate_user!

  def index
    recordings = current_user.recordings.order(recorded_date: :desc)
    today = Date.today

    # --- サマリー ---
    @total_income = recordings.sum(:amount)
    @total_minutes = calculate_minutes(@total_income)
    @lifetime_display = format_life_time(@total_minutes)

    first_record = recordings.minimum(:recorded_date)
    @days_since_start = first_record ? (today - first_record).to_i + 1 : 0
    @recording_days = recordings.distinct.count(:recorded_date)

    # --- 月別集計 ---
    monthly_data = recordings
      .group("DATE_FORMAT(recorded_date, '%Y-%m')")
      .sum(:amount)
      .sort_by { |k, _| k }
      .reverse

    max_monthly = monthly_data.map(&:last).max || 1

    @months = monthly_data.map do |month_str, amount|
      date = Date.parse("#{month_str}-01")
      minutes = calculate_minutes(amount)
      {
        label: date.strftime("%Y年%-m月"),
        amount: amount,
        time: format_life_time(minutes),
        percent: (amount.to_f / max_monthly * 100).round
      }
    end

    # --- 最近の記録（直近30件） ---
    @recent = recordings.limit(30).map do |r|
      minutes = calculate_minutes(r.amount)
      {
        date: r.recorded_date,
        amount: r.amount,
        time: format_time(minutes)
      }
    end
  end
end
