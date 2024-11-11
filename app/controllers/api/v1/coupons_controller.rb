class Api::V1::CouponsController < ApplicationController
    def show
        coupon = Coupon.find(params[:id])
    
        render json: CouponSerializer.new(coupon, params: {id: params[:id]}), status: :ok  
    end

    def create
        coupon = Coupon.create!(coupon_params)
        render json: CouponSerializer.new(coupon), status: :created
    end

    def update
        coupon = Coupon.find(params[:id])
  
        if params[:active].nil?
            render json: ErrorSerializer.format_update_active_only, status: :bad_request
            return
        end
        change_active_to = params[:active]

        if change_active_to == "false" && Coupon.attached_to_pending_invoice(coupon.id)
            render json: ErrorSerializer.format_coupon_deactivation_response, status: :bad_request
        else
            coupon.update!(active: change_active_to)
            render json: CouponSerializer.new(coupon)
        end
    end

    private

    def coupon_params
      params.permit(:name, :code, :discount, :active, :percent_discount, :description, :merchant_id)
    end
end