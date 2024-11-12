require "rails_helper"

RSpec.describe "Coupon endpoints" , :type => :request do
    before :each do
        @merchant_1 = create(:merchant)
        @merchant_2 = create(:merchant)

        @customer1 = create(:customer)
        @customer2 = create(:customer)

        @coupon_1 = create(:coupon, code: "BOGO50", active: true, merchant_id: @merchant_1.id)
        @coupon_2 = create(:coupon, active: true, merchant_id: @merchant_2.id)

        @invoice1 = create(:invoice, customer_id: @customer1.id, merchant_id: @merchant_1.id, status: "packaged", coupon_id: @coupon_1.id)
    end

    describe "Coupon show" do
        it "should show a coupon and it's attributes" do
            get api_v1_coupon_path(@coupon_1)

            coupon = JSON.parse(response.body, symbolize_names: true)
            
            expect(response.status).to eq(200)
            expect(coupon).to have_key(:data)

            expect(coupon[:data]).to have_key(:id)
            expect(coupon[:data][:id]).to be_a(String)

            expect(coupon[:data]).to have_key(:id)
            expect(coupon[:data][:type]).to be_a(String)
            expect(coupon[:data][:type]).to eq("coupon")

            expect(coupon[:data][:attributes][:name]).to eq(@coupon_1.name)
            expect(coupon[:data][:attributes][:code]).to eq(@coupon_1.code)
            expect(coupon[:data][:attributes][:discount]).to eq(@coupon_1.discount)
            expect(coupon[:data][:attributes][:active]).to eq(@coupon_1.active)
            expect(coupon[:data][:attributes][:percent_discount]).to eq(@coupon_1.percent_discount)
            expect(coupon[:data][:attributes][:description]).to eq(@coupon_1.description)
            expect(coupon[:data][:attributes][:merchant_id]).to eq(@coupon_1.merchant_id)
            expect(coupon[:data][:attributes][:times_used]).to eq(1)
        end

        it "should give an error if item number doesnt exist" do
            get api_v1_coupon_path(9999)

            json_response = JSON.parse(response.body, symbolize_names: true)
           
            expect(response).to have_http_status(:not_found)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Coupon with 'id'=9999"])
        end
    end

    describe "Coupon create" do
        it "can create a new coupon for a merchant" do
            name ="Discount on Items"
            code = "10for10"
            discount = 10
            active = true
            percent_discount = false
            description = "10 off your order"
            merchant_id = @merchant_1.id

            body = {
                name: name,
                code: code,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                description: description,
                merchant_id: merchant_id
            }
            post api_v1_coupons_path,params: body, as: :json

            coupon = JSON.parse(response.body, symbolize_names: true)

            expect(response).to have_http_status(:created)
            expect(coupon[:data][:attributes][:name]).to eq(name)
            expect(coupon[:data][:attributes][:discount]).to eq(discount)
            expect(coupon[:data][:attributes][:active]).to eq(active)
            expect(coupon[:data][:attributes][:percent_discount]).to eq(percent_discount)
            expect(coupon[:data][:attributes][:merchant_id]).to eq(merchant_id)
        end

        it "cannot create an coupon with a non-unique code" do
            name = "Coupon 1"
            code ="BOGO50"
            discount = 10
            active = true
            percent_discount = false
            description = "10 off your order"
            merchant_id = @merchant_2.id

            body = {
                name: name,
                code: code,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                description: description,
                merchant_id: merchant_id
            }

            post api_v1_coupons_path,params: body, as: :json

            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Code has already been taken"])
        end
        it "cannot create an coupon with missing fields" do
            name = "Coupon Test"
            code = "1234"
            active = true
            percent_discount = false
            description = "10 off your order"
            merchant_id = @merchant_2.id

            body = {
                name: name,
                code: code,
                active: active,
                percent_discount: percent_discount,
                description: description,
                merchant_id: merchant_id
            }

            post api_v1_coupons_path,params: body, as: :json

            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Discount can't be blank, Discount is not a number"])
        end

        it "cannot create an active coupon if the merchant already has 5 active" do
            coupons = create_list(:coupon, 4, active: true, merchant_id: @merchant_1.id)
            name = "Big sale"
            code = "Sale123"
            discount = 5
            active = true
            percent_discount = true
            description = "10 off your order"
            merchant_id = @merchant_1.id

            body = {
                name: name,
                code: code,
                discount: discount,
                active: active,
                percent_discount: percent_discount,
                description: description,
                merchant_id: merchant_id
            }
            post api_v1_coupons_path,params: body, as: :json

            json = JSON.parse(response.body, symbolize_names: true)
            expect(response.status). to eq(422)
            expect(json[:message]).to eq("Your query could not be completed")
            expect(json[:errors]).to eq(["Validation failed: Only 5 coupons can be active for one merchant"])
        end
    end

    describe "Change coupon active status" do
        it "can deactivate a coupon if it has no invoices" do
            patch api_v1_coupon_path(@coupon_2, active: false)

            coupon = JSON.parse(response.body, symbolize_names: true)
 
            expect(response.status).to eq(200)
            expect(coupon[:data][:id]).to eq(@coupon_2.id.to_s)
            expect(coupon[:data][:attributes][:active]).to eq(false)
        end

        it "cannot deactive a coupon if tied to pending invoices" do
            patch api_v1_coupon_path(@coupon_1, active: false)
      
            json_response = JSON.parse(response.body, symbolize_names: true)
       
            expect(response.status).to eq(400)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Cannot deactivate a coupon that's attached to invoices"])
        end

        it "cannot deactivate a coupon that doesn't exist" do
            patch api_v1_coupon_path(99999, active: false)

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response.status).to eq(404)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Coupon with 'id'=99999"])
        end

        it "can activate a coupon" do
            coupon_test = create(:coupon, active: false, merchant_id: @merchant_1.id)

            patch api_v1_coupon_path(coupon_test, active: true)

            coupon = JSON.parse(response.body, symbolize_names: true)
      
            expect(response.status).to eq(200)
            expect(coupon[:data][:id]).to eq(coupon_test.id.to_s)
            expect(coupon[:data][:attributes][:active]).to eq(true)
        end

        it "cannot activate a coupon if there are already 5 active coupons for merchant" do
            coupons = create_list(:coupon, 4, active: true, merchant_id: @merchant_1.id)
            coupon_test = create(:coupon, active: false, merchant_id: @merchant_1.id)

            patch api_v1_coupon_path(coupon_test, active: true)

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response.status).to eq(422)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Validation failed: Only 5 coupons can be active for one merchant"])
        end

        it "cannot activate a coupon that doesn't exist" do
            patch api_v1_coupon_path(99999, active: true)

            json_response = JSON.parse(response.body, symbolize_names: true)

            expect(response.status).to eq(404)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["Couldn't find Coupon with 'id'=99999"])
        end

        it "requires active to be in the query" do
            patch api_v1_coupon_path(@coupon_2)

            json_response = JSON.parse(response.body, symbolize_names: true)
            expect(response.status).to eq(400)
            expect(json_response[:message]).to eq("Your query could not be completed")
            expect(json_response[:errors]).to eq(["The active parameter is required to change the active status"])
        end
    end
end