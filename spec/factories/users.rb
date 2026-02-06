FactoryBot.define do
  factory :user do
    nickname              { Faker::Name.initials(number: 2) } # 例: "AB"
    email                 { Faker::Internet.email } # 動的に生成される一意なメールアドレス
    password              { 'abc123' } # 半角英数字混合の固定パスワード
    password_confirmation { 'abc123' } # パスワードと一致
    hourly_rate           { Faker::Number.between(from: 1, to: 5000) } # 範囲内でランダムに生成される時給
  end
end
