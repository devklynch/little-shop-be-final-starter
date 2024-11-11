class Coupon < ApplicationRecord
    validates :code, presence: true, uniqueness: true
    validates :name, presence: true
    validates :discount, presence: true, numericality: true
    validates :active, inclusion: { in: [true,false]}
    validates :percent_discount, inclusion: { in: [true,false]}
    validates :description, presence: true
    validates :merchant_id, presence: true
    belongs_to :merchant
    has_many :invoices

    validate :merchant_coupon_limit, on: :create
    validate :merchant_coupon_limit, if: -> {active_changed? && active?}

    def merchant_coupon_limit
        if merchant.coupons.where(active: true).count >= 5
            errors.add(:base, "Only 5 coupons can be active for one merchant")
        end
    end

    def self.attached_to_pending_invoice(coupon_id)
         (joins(:invoices).where("coupon_id = ? AND status = ?", coupon_id,"packaged").count) >0
    end
end