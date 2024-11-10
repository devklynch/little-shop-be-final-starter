class CouponSerializer
    include JSONAPI::Serializer
    attributes :name, :description, :discount, :active, :percent_discount, :merchant_id
    attributes :times_used do |coupon,params|
        Invoice.coupon_count(params[:id])
    end
  end