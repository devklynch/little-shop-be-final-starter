FactoryBot.define do
  factory :invoice do
    status { "shipped" }
    customer
    merchant
    coupon_id
  end
end