FactoryBot.define do
    factory :coupon do
        name {Faker::Commerce.promotion_code}
        description {Faker::Commerce.product_name}
        discount {Faker::Number.between(from:1, to:10)}
        percent_discount {Faker::Boolean.boolean}
        active {Faker::Boolean.boolean}
        merchant
    end
end