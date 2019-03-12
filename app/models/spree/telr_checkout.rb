module Spree
  class TelrCheckout < ActiveRecord::Base

  	def error_msg
  		status = telr_errors.last.dig("order","transaction","status")

		msg = "999:Unknown Error occurred"
		msg = (telr_errors.last.dig("order","transaction","code").to_s + ':' +telr_errors.last.dig("order","transaction","message").to_s) || msg

  		msg
  	end
  end
end