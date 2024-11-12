require 'rails_helper'

describe Coupon, type: :model do
  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :code }
    it { should validate_presence_of :discount }
    it { should validate_presence_of :description }
  end

  describe 'relationships' do
    it { should belong_to :merchant }
  end

  describe "merchant coupon limit tests" do
    before :each do
        @merchant1=create(:merchant)
        @coupon = create(:coupon, active: true, merchant_id: @merchant1.id)
        coupons = create_list(:coupon, 4, active: true, merchant_id: @merchant1.id)
        customer1 = create(:customer)
        invoice_coupon1 = create(:invoice, customer_id: (customer1.id), merchant_id: @merchant1.id, status: "packaged", coupon_id: @coupon.id)
        invoice_coupon2 = create(:invoice,customer_id: (customer1.id), merchant_id: @merchant1.id, status: "shipped", coupon_id: @coupon.id)
    end

    it "does not create another coupon" do
        coupon = build(:coupon, active: true, merchant_id: @merchant1.id)
    
        expect(coupon).not_to be_valid
        expect(coupon.errors[:base]).to include("Only 5 coupons can be active for one merchant")
    end

    it "can check how many invoices are associated with a packaged invoice" do
        expect(Coupon.attached_to_pending_invoice(@coupon.id)).to eq(true)
    end

    it "cannot create a percent_discount coupon with a discount value greater than 100" do
      coupon = build(:coupon, percent_discount: true, discount: 120)
   
      expect(coupon).not_to be_valid
      expect(coupon.errors[:base]).to include("A percent discount coupon cannot exceed 100 in the discount")
    end
  end
end