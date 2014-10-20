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

  def self.calculate_amounts(purchase_order_detail_id, pending, unit_price, current_igv)
    data_result = Array.new
    initial_total = pending*unit_price
    discounts_before_igv = 0
    discounts_after_igv = 0
    total_without_igv = 0
    total_with_igv = 0
    total_net_with_igv = 0

    PurchaseOrderDetail.find(purchase_order_detail_id).purchase_order_extra_calculations.where("apply LIKE 'before'").each do |extra_calculation|
      if extra_calculation.type == 'percent'
        value = extra_calculation.value.to_f/100
        if extra_calculation.operation == "minius"
          discounts_before_igv += (initial_total*value)*-1
        else
          discounts_before_igv += initial_total*value
        end
      elsif extra_calculation.type == 'soles'
        value = extra_calculation.value.to_f
        if extra_calculation.operation == "minius"
          discounts_before_igv += (value*-1)
        else
          discounts_before_igv += value
        end
      end
    end

    total_without_igv = initial_total + discounts_before_igv
    total_with_igv = (current_igv+1) * total_without_igv

    PurchaseOrderDetail.find(purchase_order_detail_id).purchase_order_extra_calculations.where("apply LIKE 'before'").each do |extra_calculation|
      if extra_calculation.type == 'percent'
        value = extra_calculation.value.to_f/100
        if extra_calculation.operation == "minius"
          discounts_after_igv += (total_with_igv*value)*-1
        else
          discounts_after_igv += total_with_igv*value
        end
      elsif extra_calculation.type == 'soles'
        value = extra_calculation.value.to_f
        if extra_calculation.operation == "minius"
          discounts_after_igv += (value*-1)
        else
          discounts_after_igv += value
        end
      end
    end

    total_net_with_igv = total_with_igv + discounts_after_igv

    data_result = [ initial_total, discounts_before_igv, discounts_after_igv, total_without_igv, total_with_igv, total_net_with_igv ]
    # [0] => initial_total
    # [1] => discounts_before_igv
    # [2] => discounts_after_igv
    # [3] => total_without_igv
    # [4] => total_with_igv
    # [5] => total_net_with_igv

    return data_result

  end

end
