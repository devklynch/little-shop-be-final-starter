class Api::V1::CouponsController < ApplicationController
    def show
        coupon = Coupon.find(params[:id])
    
        render json: CouponSerializer.new(coupon, params: {id: params[:id]}), status: :ok  
    end

    def create
        coupon = Coupon.create!(coupon_params)
        render json: CouponSerializer.new(coupon), status: :created
    end

    def activate
        coupon = Coupon.find(params[:id])
        coupon.update!(active: true)
        render json: CouponSerializer.new(coupon)
    end

    def deactivate
        coupon = Coupon.find(params[:id])
        coupon.update!(active: false)
        render json: CouponSerializer.new(coupon)
    end

    private

    def coupon_params
      params.permit(:name, :discount, :active, :percent_discount, :merchant_id)
    end
end