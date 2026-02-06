module TimeFormatting
  extend ActiveSupport::Concern

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

  def format_life_time(total_minutes)
    days = total_minutes / (60 * 24)
    remaining = total_minutes % (60 * 24)
    hours = remaining / 60
    mins = remaining % 60

    parts = []
    parts << "#{days}日" if days > 0
    parts << "#{hours}時間" if hours > 0
    parts << "#{mins}分" if mins > 0 && days == 0
    parts.empty? ? "0分" : parts.join
  end
end
