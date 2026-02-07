FactoryBot.define do
  factory :recording do
    amount        { Faker::Number.between(from: 100, to: 5000) }
    recorded_date { Date.today }
    note          { nil }
    association :user

    trait :with_note do
      note { %w[自炊した 電車にした コーヒー我慢 サブスク解約].sample }
    end

    trait :yesterday do
      recorded_date { Date.yesterday }
    end
  end
end
