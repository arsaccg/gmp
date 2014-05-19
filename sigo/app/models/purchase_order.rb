class PurchaseOrder < ActiveRecord::Base
	has_many :purchase_order_details
	has_many :state_per_order_purchases
  belongs_to :entity
	belongs_to :cost_center
  belongs_to :user
  belongs_to :money
  belongs_to :method_of_payment

  accepts_nested_attributes_for :purchase_order_details, :allow_destroy => true
  belongs_to :rep_inv_money, :foreign_key => 'money_id'
  
  state_machine :state, :initial => :pre_issued do

    event :issue do
      transition [:pre_issued, :revised] => :issued
    end

    event :observe do
      transition :issued => :pre_issued
    end

    event :revise do
      transition [:issued, :approved] => :revised
    end

    event :approve do
      transition :revised => :approved
    end

    event :cancel do
      transition [:pre_issued, :issued, :revised, :approved] => :canceled
    end
  end

  def self.get_total_amount_per_delivery_order(delivery_detail_id)
    return ActiveRecord::Base.connection.execute("SELECT amount FROM `delivery_order_details` WHERE `id` = #{delivery_detail_id}")
  end

  def self.get_total_amount_items_requested_by_purchase_order(delivery_detail_id)
    return ActiveRecord::Base.connection.execute("SELECT SUM( amount ) AS 'sum' FROM `purchase_order_details` WHERE `delivery_order_detail_id` = #{delivery_detail_id} GROUP BY `delivery_order_detail_id`")
  end

  def self.get_approved_by_company(company_id)
    joins{cost_center.company}
    .where{(companies.id.eq "#{company_id}") &
           (purchase_orders.state.eq 'approved')}
  end

  def self.get_approved_by_company_and_supplier(company_id, supplier_id)
    joins{cost_center.company}
    .where{(companies.id.eq "#{company_id}") &
           (purchase_orders.entity_id.eq "#{supplier_id}") &
           (purchase_orders.state.eq 'approved')}
  end
end
