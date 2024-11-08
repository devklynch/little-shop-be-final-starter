class Invoice < ApplicationRecord
  belongs_to :customer
  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :transactions, dependent: :destroy

  validates :status, inclusion: { in: ["shipped", "packaged", "returned"] }

  def self.coupon_count(coupon_id)
    where("coupon_id = ?", coupon_id).count
  end

end