require "rails_helper"

RSpec.describe "Coupon endpoints" , :type => :request do
    before :each do
        @merchant_1 = Merchant.create!(name: "Merchant 1")
        @merchant_2 = Merchant.create!(name: "Merchant 2")
    end

    describe "Merchant coupon show" do
        
    end
end