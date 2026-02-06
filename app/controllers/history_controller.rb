class HistoryController < ApplicationController
  include TimeFormatting
  before_action :authenticate_user!

  def index
    all_recordings = current_user.recordings
    today = Date.today

    # --- サマリー ---
    @total_income = all_recordings.sum(:amount)
    @total_minutes = calculate_minutes(@total_income)
    @lifetime_display = format_life_time(@total_minutes)

    first_record = all_recordings.minimum(:recorded_date)
    @days_since_start = first_record ? (today - first_record).to_i + 1 : 0
    @recording_days = all_recordings.distinct.count(:recorded_date)

    # --- 取り戻した人生でできること ---
    @life_equivalents = build_life_equivalents(@total_minutes)

    # --- 月別集計 ---
    monthly_data = all_recordings
      .reorder(nil)
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
    @recent = all_recordings.order(recorded_date: :desc).limit(30).map do |r|
      minutes = calculate_minutes(r.amount)
      {
        date: r.recorded_date,
        amount: r.amount,
        time: format_time(minutes)
      }
    end
  end

  private

  # 取り戻した時間を具体的な体験に変換
  def build_life_equivalents(total_minutes)
    return [] if total_minutes == 0

    equivalents = [
      { min: 30,    unit: 30,   text: "カフェでひと息",         per: "1回30分" },
      { min: 60,    unit: 60,   text: "好きな音楽アルバム",     per: "1枚約60分" },
      { min: 120,   unit: 120,  text: "映画鑑賞",              per: "1本約2時間" },
      { min: 180,   unit: 180,  text: "読書（文庫本1冊）",      per: "1冊約3時間" },
      { min: 360,   unit: 360,  text: "日帰り小旅行",           per: "1回約6時間" },
      { min: 1440,  unit: 1440, text: "まる1日の完全な自由",     per: "24時間" },
    ]

    results = []
    equivalents.each do |eq|
      count = total_minutes / eq[:unit]
      next if count == 0
      results << { text: eq[:text], count: count, per: eq[:per] }
    end

    results.last(3) # 最も大きいスケールの3つだけ表示
  end
end
