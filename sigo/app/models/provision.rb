class Provision < ActiveRecord::Base
  belongs_to :cost_center
  belongs_to :document_provision
  has_many :provision_details

  accepts_nested_attributes_for :provision_details, :allow_destroy => true

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
end
