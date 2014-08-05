class Provision < ActiveRecord::Base
  belongs_to :cost_center
  belongs_to :document_provision
  belongs_to :payment_order
  belongs_to :entity
  has_many :provision_details
  has_many :provision_direct_purchase_details

  accepts_nested_attributes_for :provision_details, :allow_destroy => true
  accepts_nested_attributes_for :provision_direct_purchase_details, :allow_destroy => true

  def self.update_received_order(total_amount, order_id, type_of_order)
    case type_of_order
      when "purchase_order" then
        order_amount = PurchaseOrderDetail.find(order_id).amount
        if order_amount == total_amount
          PurchaseOrderDetail.find(order_id).update_attributes(:received_provision => 1)
        end
      when "service_order" then
        order_amount = OrderOfServiceDetail.find(order_id).amount
        if order_amount == total_amount
          OrderOfServiceDetail.find(order_id).update_attributes(:received => 1)
        end
      else raise "Unknown Order"
    end
  end

  def self.sumProvisionDetail(provision_id)
    sum = 0
    provisiondetails = ProvisionDetail.where("provision_id = ?",provision_id)
    puts provisiondetails.inspect
    provisiondetails.each do |pd|
      sum = pd.amount * pd.current_unit_price rescue 1
    end
    return sum
  end

  def self.sumProvisionDetail2(provision_id)
    sum = 0
    provisiondetails = ProvisionDetail.where("provision_id = ?",provision_id)
    provisiondetails.each do |pd|
      sum = pd.amount * pd.unit_price_igv rescue 1
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
end
