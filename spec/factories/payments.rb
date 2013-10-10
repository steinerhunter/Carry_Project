# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    status "MyString"
    amount 1.5
    transaction_number "MyString"
  end
end
