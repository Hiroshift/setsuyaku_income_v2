FactoryBot.define do
  factory :recording do
    amount { 1 } # 金額をデフォルトで1に設定
    recorded_date { Date.today } # 今日の日付をデフォルトで設定
    association :user # Userとの関連付けを明示
  end
end
