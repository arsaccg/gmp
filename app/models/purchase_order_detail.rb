class PurchaseOrderDetail < ActiveRecord::Base
	belongs_to :delivery_order_detail
	belongs_to :purchase_order
	belongs_to :user

	def self.get_total_received(id)
	  @received = ActiveRecord::Base.connection.execute("SELECT SUM(amount) FROM `stock_input_details` WHERE `purchase_order_detail_id` = #{id}")
	  if @received != nil
	    return @received.first.at(0).to_i
	  else
	    return 0
	  end
	end
end
