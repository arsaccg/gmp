class Provision < ActiveRecord::Base
  belongs_to :cost_center
  belongs_to :document_provision
  has_one :payment_order
  belongs_to :money
  belongs_to :entity
  has_many :provision_details
  has_many :provision_direct_purchase_details

  accepts_nested_attributes_for :provision_details, :allow_destroy => true
  accepts_nested_attributes_for :provision_direct_purchase_details, :allow_destroy => true

  def self.update_received_order(total_amount, order_id, type_of_order)
    case type_of_order
      when "purchase_order" then
        order_amount = PurchaseOrderDetail.find(order_id).amount
        if order_amount.to_i == total_amount.to_i
          PurchaseOrderDetail.find(order_id).update_attributes(:received_provision => 1)
        end
      when "service_order" then
        order_amount = OrderOfServiceDetail.find(order_id).amount
        if order_amount.to_i == total_amount.to_i
          OrderOfServiceDetail.find(order_id).update_attributes(:received => 1)
        end
      else raise "Unknown Order"
    end
  end

  # Functions for Direct Purchase Provisions

  def self.sumProvisionDetail(provision_id)
    sum = 0
    Provision.find(provision_id).provision_details.each do |pd|
      sum += pd.amount.to_f * pd.current_unit_price.to_f
    end
    return sum
  end

  def self.sumProvisionDetail2(provision_id)
    sum = 0
    Provision.find(provision_id).provision_details.each do |provision_detail|
      sum += provision_detail.net_price_after_igv.to_f
    end
    return sum
  end

  # Functions for Direct Purchase Provisions

  def self.sumProvisionDetailDirectPurchaseBeforeIGV(provision_obj)
    sum = 0

    provision_obj.provision_direct_purchase_details.each do |direct_purchase|
      sum += direct_purchase.unit_price_before_igv
    end

    return sum
  end

  def self.sumProvisionDetailDirectPurchaseAfterIGV(provision_obj)
    sum = 0

    provision_obj.provision_direct_purchase_details.each do |direct_purchase|
      sum += (direct_purchase.unit_price_before_igv.to_f + direct_purchase.quantity_igv.to_f + direct_purchase.discount_after.to_f)
    end
    
    return sum
  end

  def self.getOwnArticles(word, name)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles_from_cost_center_" + name.to_s + " a, unit_of_measurements u 
      WHERE (a.code LIKE '05%' || a.code LIKE '04%' || a.code LIKE '03%' || a.code LIKE '02%')
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND a.unit_of_measurement_id = u.id
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.get_amount(order_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT SUM(amount)
      FROM provision_direct_purchase_details
      WHERE order_detail_id = #{order_id}
      GROUP BY amount
    ").first
    return mysql_result
  end  
end
