FactoryBot.define do
    factory :coupon do
        name {Faker::Commerce.promotion_code}
        discount {Faker::Number.between(from:1, to:10)}
        percent_discount {Faker::Boolean.boolean}
        active {Faker::Boolean.boolean}
        merchant
    end
end