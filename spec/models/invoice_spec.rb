require "rails_helper"

RSpec.describe Invoice do
  it { should belong_to :merchant }
  it { should belong_to :customer }
  it { should validate_inclusion_of(:status).in_array(%w(shipped packaged returned)) }

  it "can only have a coupon added if they belong to the same merchant" do
    merchant = Merchant.create!(name: "Merchant Invoices")
    merchant2 = Merchant.create!(name: "Merchant Invoices2")
    coupon = FactoryBot.create(:coupon, active:true, merchant_id: merchant2.id)
    invoice_coupon = build(:invoice, customer: @customer1, merchant_id: merchant.id, status: "shipped", coupon_id: coupon.id)

    expect(invoice_coupon).not_to be_valid
    expect(invoice_coupon.errors[:base]).to include("Invoice and coupon must belong to the same merchant")
  end
end