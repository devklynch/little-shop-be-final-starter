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
        invoice_error = {
    
                message: "Your query could not be completed",
                errors: "Cannot deactivate a coupon that's attached to invoices"
              }
            
        coupon = Coupon.find(params[:id])
        if Invoice.coupon_count(coupon.id) > 0
            render json: invoice_error, status: :bad_request
           
        else
        coupon.update!(active: false)
        render json: CouponSerializer.new(coupon)
        end
    end

    private

    def coupon_params
      params.permit(:name, :discount, :active, :percent_discount, :merchant_id)
    end

    def check_invoices
    invoice_error = {
            errors: [
              {
                status: "400",
                message: "Cannot deactivate a coupon that's attached to invoices"
              }
            ]
          }
        if coupon.times_used >0
            render jso: invoice_error, status: :bad_request
        end
    end
end