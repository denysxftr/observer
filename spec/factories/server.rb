FactoryGirl.define do
  factory :server do
    name 'Test server'
    is_ok true

    factory :server_with_isues do
      is_ok false
      issues [:cpu_high, :ram_high, :swap_high]
    end
  end
end
