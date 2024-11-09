require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
    before :each do
        @merchant_2 = FactoryBot.create(:merchant)
        @merchant_1 = FactoryBot.create(:merchant)
        @merchant_3 = FactoryBot.create(:merchant)
      
        @coupon_1 = FactoryBot.create(:coupon, active: true, merchant_id: @merchant_1.id)
        @coupon_2 = FactoryBot.create(:coupon, merchant_id: @merchant_2.id)
        @coupon_3 = FactoryBot.create(:coupon, merchant_id: @merchant_2.id)
        @coupon_4 = FactoryBot.create(:coupon, active: true, merchant_id: @merchant_1.id)
        @coupon_5 = FactoryBot.create(:coupon, active: false, merchant_id: @merchant_1.id)

    end

    describe "Get a merchant's coupons" do
        it "can return an array of a provided merchant's coupons" do
            get "/api/v1/merchants/#{@merchant_2.id}/coupons"

            coupons = JSON.parse(response.body, symbolize_names: true)
    
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(2)
            expect(coupons[:data][0][:id]).to eq(@coupon_2.id.to_s)
            expect(coupons[:data][1][:id]).to eq(@coupon_3.id.to_s)
        end
        
        it "can return an empty array if there are no coupons" do
            get "/api/v1/merchants/#{@merchant_3.id}/coupons"

            coupons = JSON.parse(response.body, symbolize_names: true)
          
            expect(response.status).to eq(200)
            expect(coupons[:data]).to eq([])
        end

        it "can return an error if the merchant does not exist" do
            get "/api/v1/merchants/999999/coupons"

            json_response = JSON.parse(response.body, symbolize_names: true)
   
            expect(response).to have_http_status(:not_found)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Merchant with 'id'=999999"])
        end

        it "can give a merchant's only active invoices if queried" do
            get "/api/v1/merchants/#{@merchant_1.id}/coupons?active=true"

            coupons = JSON.parse(response.body, symbolize_names: true)
            #binding.pry
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(2)
            expect(coupons[:data][0][:id]).to eq(@coupon_1.id.to_s)
            expect(coupons[:data][1][:id]).to eq(@coupon_4.id.to_s)

        end

        it "can give a merchant's only inactive invoices if queried" do
            get "/api/v1/merchants/#{@merchant_1.id}/coupons?active=false"

            coupons = JSON.parse(response.body, symbolize_names: true)
            #binding.pry
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(1)
            expect(coupons[:data][0][:id]).to eq(@coupon_5.id.to_s)

        end
    end

end