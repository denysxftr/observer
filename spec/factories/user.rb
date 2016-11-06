FactoryGirl.define do
  factory :user do
    name 'Test user'
    role 'user'
    email 'example@example.com'
    password '12345678'

    factory :user_admin do
      name 'Test admin'
      role 'admin'
      email 'example_admin@example.com'
    end
  end
end
