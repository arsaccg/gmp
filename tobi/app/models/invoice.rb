class Invoice < ActiveRecord::Base
	has_many :charges
	belongs_to :valorization

	state_machine :status, :initial => :pending do
		event :paid do
			transition :pending => :paided
		end
	end
end