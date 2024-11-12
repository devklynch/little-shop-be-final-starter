require "rails_helper"

RSpec.describe "Merchant coupons endpoints" do
    before :each do
        @merchant_1 = create(:merchant)
        @merchant_2 = create(:merchant)
        @merchant_3 = create(:merchant)
      
        @coupon_1 = create(:coupon, active: true, merchant_id: @merchant_1.id)
        @coupon_2 = create(:coupon, merchant_id: @merchant_2.id)
        @coupon_3 = create(:coupon, merchant_id: @merchant_2.id)
        @coupon_4 = create(:coupon, active: true, merchant_id: @merchant_1.id)
        @coupon_5 = create(:coupon, active: false, merchant_id: @merchant_1.id)
    end

    describe "Get a merchant's coupons" do
        it "can return an array of a provided merchant's coupons" do
            get api_v1_merchant_coupons_path(@merchant_2)

            coupons = JSON.parse(response.body, symbolize_names: true)
    
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(2)
            expect(coupons[:data][0][:id]).to eq(@coupon_2.id.to_s)
            expect(coupons[:data][1][:id]).to eq(@coupon_3.id.to_s)
        end
        
        it "can return an empty array if there are no coupons" do
            get api_v1_merchant_coupons_path(@merchant_3)

            coupons = JSON.parse(response.body, symbolize_names: true)
          
            expect(response.status).to eq(200)
            expect(coupons[:data]).to eq([])
        end

        it "can return an error if the merchant does not exist" do
            get api_v1_merchant_coupons_path(999999)

            json_response = JSON.parse(response.body, symbolize_names: true)
   
            expect(response).to have_http_status(:not_found)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Merchant with 'id'=999999"])
        end

        it "can give a merchant's only active invoices if queried" do
            get api_v1_merchant_coupons_path(@merchant_1, active: true)

            coupons = JSON.parse(response.body, symbolize_names: true)
    
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(2)
            expect(coupons[:data][0][:id]).to eq(@coupon_1.id.to_s)
            expect(coupons[:data][1][:id]).to eq(@coupon_4.id.to_s)
        end

        it "can give a merchant's only inactive invoices if queried" do
            get api_v1_merchant_coupons_path(@merchant_1, active: false)

            coupons = JSON.parse(response.body, symbolize_names: true)
      
            expect(response.status).to eq(200)
            expect(coupons[:data].count).to eq(1)
            expect(coupons[:data][0][:id]).to eq(@coupon_5.id.to_s)
        end
    end

end