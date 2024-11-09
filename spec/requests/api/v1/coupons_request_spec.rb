require "rails_helper"

RSpec.describe "Coupon endpoints" , :type => :request do
    before :each do
        @merchant_1 = Merchant.create!(name: "Merchant 1")
        @merchant_2 = Merchant.create!(name: "Merchant 2")

        @customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
        @customer2 = Customer.create!(first_name: "Jimmy", last_name: "John")

        @coupon_1 = Coupon.create!(name: "Coupon 1", discount: 10, active: true, percent_discount: false, merchant_id: @merchant_1.id)
        @coupon_2 = Coupon.create!(name: "Coupon 2", discount: 5, active: true, percent_discount: true, merchant_id: @merchant_2.id)

        @invoice1 = Invoice.create!(customer_id: (@customer1.id), merchant_id: @merchant_1.id, status: "shipped", coupon_id: @coupon_1.id)
       #@invoice2 = Invoice.create!(customer: @customer1.id, merchant: @merchant2.id, status: "shipped",coupon_id: coupon_1.id)
       
    end

    describe "Coupon show" do
        it "should show a coupon and it's attributes" do
            #get api_v1_coupons_path(@coupon_1)
            get "/api/v1/coupons/#{@coupon_1.id}"

            coupon = JSON.parse(response.body, symbolize_names: true)
            
            expect(response.status).to eq(200)
            expect(coupon).to have_key(:data)

            expect(coupon[:data]).to have_key(:id)
            expect(coupon[:data][:id]).to be_a(String)

            expect(coupon[:data]).to have_key(:id)
            expect(coupon[:data][:type]).to be_a(String)
            expect(coupon[:data][:type]).to eq("coupon")

            expect(coupon[:data][:attributes][:name]).to eq(@coupon_1.name)
            expect(coupon[:data][:attributes][:discount]).to eq(@coupon_1.discount)
            expect(coupon[:data][:attributes][:active]).to eq(@coupon_1.active)
            expect(coupon[:data][:attributes][:percent_discount]).to eq(@coupon_1.percent_discount)
            expect(coupon[:data][:attributes][:merchant_id]).to eq(@coupon_1.merchant_id)
            expect(coupon[:data][:attributes][:times_used]).to eq(1)
        end

        it "should give an error if item number doesnt exist" do
            #get api_v1_coupons_path(1)
            get "/api/v1/coupons/9999"

            json_response = JSON.parse(response.body, symbolize_names: true)
           
            expect(response).to have_http_status(:not_found)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Coupon with 'id'=9999"])
        end
    end

    describe "Change coupon active status" do
        it "can deactivate a coupon if it has no invoices" do
            patch "/api/v1/coupons/#{@coupon_2.id}/deactivate"

            coupon = JSON.parse(response.body, symbolize_names: true)
            #binding.pry
            expect(response.status).to eq(200)
            expect(coupon[:data][:id]).to eq(@coupon_2.id.to_s)
            expect(coupon[:data][:attributes][:active]).to eq(false)
            

        end
        it "cannot deactive a coupon if tied to invoices" do
            patch "/api/v1/coupons/#{@coupon_1.id}/deactivate"

            json_response = JSON.parse(response.body, symbolize_names: true)

            #binding.pry
            expect(response.status).to eq(400)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq("Cannot deactivate a coupon that's attached to invoices")
        end
    end
end