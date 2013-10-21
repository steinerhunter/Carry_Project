# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_review do
    from_user_id 1
    to_user_id 1
    type ""
    review_content "MyString"
  end
end
