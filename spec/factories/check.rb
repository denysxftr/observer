FactoryGirl.define do
  factory :check do
    name 'Test check'
    is_ok true
    url 'http://example.com'
  end
end
