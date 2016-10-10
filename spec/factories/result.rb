FactoryGirl.define do
  factory :result do
    status 200
    ip '578.56.56.01'
    add_attribute(:timeout) { 56 }
  end
end
