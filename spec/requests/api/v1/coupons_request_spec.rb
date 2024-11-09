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

    describe "Coupon create" do
        it "can create a new coupon for a merchant" do
            name = "10off"
            discount = 10
            active = true
            percent_discount = false
            merchant_id = @merchant_1.id

            body = {
                name: name,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                merchant_id: merchant_id
            }

            post "/api/v1/coupons", params: body, as: :json
            coupon = JSON.parse(response.body, symbolize_names: true)
            #binding.pry
            expect(response).to have_http_status(:created)
            expect(coupon[:data][:attributes][:name]).to eq(name)
            expect(coupon[:data][:attributes][:discount]).to eq(discount)
            expect(coupon[:data][:attributes][:active]).to eq(active)
            expect(coupon[:data][:attributes][:percent_discount]).to eq(percent_discount)
            expect(coupon[:data][:attributes][:merchant_id]).to eq(merchant_id)
        end

        it "cannot create an coupon with a non-unique name" do
            name = "Coupon 1"
            discount = 10
            active = true
            percent_discount = false
            merchant_id = @merchant_2.id

            body = {
                name: name,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                merchant_id: merchant_id
            }

            post "/api/v1/coupons", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Name has already been taken"])
        end
        it "cannot create an coupon with missing fields" do
            name = "Coupon Test"
            active = true
            percent_discount = false
            merchant_id = @merchant_2.id

            body = {
                name: name,
                active: active,
                percent_discount: percent_discount,
                merchant_id: merchant_id
            }

            post "/api/v1/coupons", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Discount can't be blank, Discount is not a number"])
        end

        it "cannot create an active coupon if the merchant already has 5 active" do
            coupons = FactoryBot.create_list(:coupon, 4, active: true, merchant_id: @merchant_1.id)
            name = "BOGO50"
            discount = 5
            active = true
            percent_discount = true
            merchant_id = @merchant_1.id

            body = {
                name: name,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                merchant_id: merchant_id
            }
            post "/api/v1/coupons", params: body, as: :json
            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Only 5 coupons can be active for one merchant"])

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

        it "can activate a coupon" do
            coupon_test = FactoryBot.create(:coupon, active: false, merchant_id: @merchant_1.id)

            patch "/api/v1/coupons/#{coupon_test.id}/activate"

            coupon = JSON.parse(response.body, symbolize_names: true)
            #binding.pry
            expect(response.status).to eq(200)
            expect(coupon[:data][:id]).to eq(coupon_test.id.to_s)
            expect(coupon[:data][:attributes][:active]).to eq(true)
        end

        it "cannot activate a coupon if there are already 5 active coupons for merchant" do
            coupons = FactoryBot.create_list(:coupon, 4, active: true, merchant_id: @merchant_1.id)
            coupon_test = FactoryBot.create(:coupon, active: false, merchant_id: @merchant_1.id)

        end
    end
end