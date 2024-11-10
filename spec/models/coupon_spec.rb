require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :discount }
    it { should validate_presence_of :description }
    #it { should validate_inclusion_of(:active).in_array([true, false]) }
    #it { should validate_inclusion_of(:percent_discount).in_array([true, false]) }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
    #it { should belong_to(:invoice).optional }
  end

  describe "merchant coupon limit tests" do
    before :each do
        @merchant1=FactoryBot.create(:merchant)
        @coupon = FactoryBot.create(:coupon, active: true, merchant_id: @merchant1.id)
        coupons = FactoryBot.create_list(:coupon, 4, active: true, merchant_id: @merchant1.id)
        customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
        invoice_coupon1 = Invoice.create!(customer_id: (customer1.id), merchant_id: @merchant1.id, status: "packaged", coupon_id: @coupon.id)
        invoice_coupon2 = Invoice.create!(customer_id: (customer1.id), merchant_id: @merchant1.id, status: "shipped", coupon_id: @coupon.id)
    end

    it "does not create another coupon" do
        coupon = FactoryBot.build(:coupon, active: true, merchant_id: @merchant1.id)
    
        expect(coupon).not_to be_valid
        expect(coupon.errors[:base]).to include("Only 5 coupons can be active for one merchant")
    end

    it "can check how many invoices are associated with a packaged invoice" do
        expect(Coupon.check_current_invoices(@coupon.id)).to eq(1)
    end
  end
end