class CouponSerializer
    include JSONAPI::Serializer
    attributes :name, :code, :description, :discount, :active, :percent_discount, :merchant_id
    attributes :times_used do |coupon,params|
        Coupon.joins(:invoices).where("coupon_id = ?", params[:id]).count
    end
  end