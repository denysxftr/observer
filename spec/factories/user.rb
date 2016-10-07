FactoryGirl.define do
  factory :user do
    name 'Test user'
    role 'user'
    email 'example@mail.com'
    password 'passw_1234'

    factory :user_admin do
      name 'Test admin'
      role 'admin'
      email 'example_admin@mail.com'
      password 'passw_1234'
    end
  end
end
