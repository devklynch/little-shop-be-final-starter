require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  describe "Invoice class models" do
    it "can count the invoices that use a specific coupon" do
    merchant = Merchant.create!(name: "Merchant Invoices")
    customer1 = Customer.create!(first_name: "Papa", last_name: "Gino")
    coupon1 = FactoryBot.create(:coupon, active:true, merchant_id: merchant.id)
    coupon2 = FactoryBot.create(:coupon, active:true, merchant_id: merchant.id)
    invoice_factory = FactoryBot.create_list(:invoice, 2,merchant: merchant)
    invoice_coupon = Invoice.create!(customer_id: (customer1.id), merchant_id: merchant.id, status: "shipped", coupon_id: coupon1.id)
    invoice_coupon2 = Invoice.create!(customer_id: (customer1.id), merchant_id: merchant.id, status: "shipped", coupon_id: coupon2.id)
    invoice_coupon3 = Invoice.create!(customer_id: (customer1.id), merchant_id: merchant.id, status: "shipped", coupon_id: coupon2.id)
    
    expect(Invoice.coupon_count(coupon1.id)).to eq(1)
    expect(Invoice.coupon_count(coupon2.id)).to eq(2)
    end

  end
end