FactoryBot.define do
  factory :task do
    name {'テストをかく'}
    description { 'カピバラを使う'}
    user
  end
end
