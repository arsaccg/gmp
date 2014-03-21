class PurchaseOrder < ActiveRecord::Base
	has_many :purchase_order_details
	has_many :state_per_order_purchases
	belongs_to :cost_center
  belongs_to :user

  accepts_nested_attributes_for :purchase_order_details

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
end
