class Api::V1::Merchants::CouponsController < ApplicationController
    def index
        merchant = Merchant.find(params[:merchant_id])
        if params[:active].present?
            coupons = merchant.coupons_filtered_by_active(params[:active])
        else
            coupons = merchant.coupons
        end
        render json: CouponSerializer.new(coupons)
      end
end