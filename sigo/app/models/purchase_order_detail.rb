class PurchaseOrderDetail < ActiveRecord::Base
	belongs_to :delivery_order_detail
	belongs_to :purchase_order, :touch => true
	belongs_to :user
	has_many :stock_input_details
	has_many :purchase_order_extra_calculations

	accepts_nested_attributes_for :purchase_order_extra_calculations, :allow_destroy => true

	def self.get_total_received(id)
	  @received = ActiveRecord::Base.connection.execute("SELECT SUM(amount) FROM `stock_input_details` WHERE `purchase_order_detail_id` = #{id}")
	  if @received != nil
	    return @received.first.at(0).to_i
	  else
	    return 0
	  end
	end

	def self.get_approved_more_items(company_id, supplier_id, list_not_in)
		joins{purchase_order.cost_center.company}
	    .where{(companies.id.eq "#{company_id}") &
	           (purchase_orders.entity_id.eq "#{supplier_id}") &
           	   (purchase_orders.state.eq "approved")}
        .where('purchase_order_details.id NOT IN (' + list_not_in.to_s + ')')
        .where('purchase_order_details.received IS NULL')
	  end
end
