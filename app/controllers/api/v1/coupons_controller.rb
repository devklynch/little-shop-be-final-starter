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
        coupon_id =coupon.id

        if Coupon.attached_to_pending_invoice(coupon_id)
            render json: ErrorSerializer.format_coupon_deactivation_response, status: :bad_request
        else
        coupon.update!(active: false)
        render json: CouponSerializer.new(coupon)
        end
    end

    private

    def coupon_params
      params.permit(:name, :code, :discount, :active, :percent_discount, :description, :merchant_id)
    end

    # def check_invoices
    # invoice_error = {
    #         # errors: [
    #         #   {
    #         #     status: "400",
    #         #     message: "Cannot deactivate a coupon that's attached to invoices"
    #         #   }
    #         # ]
    #         message: "Your query could not be completed",
    #   errors: "Cannot deactivate a coupon that's attached to invoices"
    #       }
    #     if coupon.times_used >0
    #         render json: invoice_error, status: :bad_request
    #     end
    # end
end