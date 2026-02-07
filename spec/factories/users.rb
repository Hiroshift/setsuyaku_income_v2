FactoryBot.define do
  factory :user do
    nickname              { Faker::Name.initials(number: 2) }
    email                 { Faker::Internet.unique.email }
    password              { 'abc123' }
    password_confirmation { 'abc123' }
    hourly_rate           { Faker::Number.between(from: 800, to: 3000) }
    premium               { false }

    trait :premium do
      premium { true }
    end
  end
end
