class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  belongs_to :coupon, optional: true
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }
  validate :invoice_coupon_same_merchant_check, on: :create

  private

  def invoice_coupon_same_merchant_check
    if coupon.present? && coupon.merchant_id != merchant_id
      errors.add(:base, "Invoice and coupon must belong to the same merchant")
    end
  end
end