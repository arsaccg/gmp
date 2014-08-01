class PaymentOrder < ActiveRecord::Base
	has_many :provisions
end
