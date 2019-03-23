require 'httparty'

module Spree
  class TelrController < StoreController

    def express
      @order = current_order || raise(ActiveRecord::RecordNotFound)

      begin
        result = hit
        order  = @order

        ref   = result.parsed_response.dig("order","ref")
        url   = result.parsed_response.dig("order","url")
        error =  result.parsed_response.dig("error") || []

        if(url.blank? || ref.blank?)
          flash[:error] = Spree.t('flash.generic_error', scope: 'telr', reasons: error.map{|k,v|k.to_s+':'+v.to_s}.join(','))
          redirect_to checkout_state_path(:payment)
        else
          order.payments.create!({
            source: Spree::TelrCheckout.create({
              ref: ref,
            }),
            amount: order.total,
            payment_method: payment_method
          })
          redirect_to checkout_state_path(state: :payment,telr_url:url, pmi: params['payment_method_id'] )
        end
        
      rescue => e
        flash[:error] = Spree.t('flash.connection_failed', scope: 'telr')
        redirect_to checkout_state_path(:payment)
      end
    end

    def receiver_authorized_transactions
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.next

      if order.complete?
        flash.notice = Spree.t(:order_processed_successfully)
        flash[:order_completed] = true
        session[:order_id] = nil
        redirect_to completion_route(order)
      else
        redirect_to checkout_state_path(order.state)
      end
    end

    def receiver_decl_transactions
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.next
      flash[:error] = order.payments.failed.last.source.error_msg + " - Please try again later"
      redirect_to checkout_state_path(order.state)
    end

    def receiver_cancelled_transactions
      order = current_order || raise(ActiveRecord::RecordNotFound)
      order.next
      flash[:error] = order.payments.failed.last.source.error_msg.to_s + " - Please try again later"
      redirect_to checkout_state_path(order.state)
    end

    def hit
      ::HTTParty.post(Spree::Gateway::TelrGateway::URL, 
          :body => payload.to_json,
          :headers => { 'Content-Type' => 'application/json' } )
    end

    private
    def payment_method
      Spree::PaymentMethod.find(params[:payment_method_id])
    end

    def payload
      address = @order.billing_address
      { 
        method: 'create',
        store: payment_method.preferred_merchant_id,
        authkey: payment_method.preferred_api_key,
        framed: 2,
        order: {
          cartid: @order.number,
          test: payment_method.preferred_test_mode,
          amount: @order.total,
          currency: 'AED',
          description: 'New Order | Transaction',
        },
        customer: {
          email: @order.email,
          name: {
            title: @order.email.split('@').first
          },
          address:{
            city: address.city,
            country: address.country.iso,
            line1: address.address1,
            line2: address.address2,
            line3: address.address3,
            areacode: address.zipcode,
            state: address.state.name 
          }
        },
        return: {
          authorised: telr_v2_authorized_url,
          declined:   telr_v2_declined_url,
          cancelled:  telr_v2_cancelled_url
        }
      }
    end

    def completion_route(order)
      order_path(order)
    end
  end
end



