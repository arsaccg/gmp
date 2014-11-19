class WarehouseOrder < ActiveRecord::Base
  has_many :warehouse_order_details
  has_many :state_per_warehouse_orders
  accepts_nested_attributes_for :warehouse_order_details, :allow_destroy => true
  
  state_machine :state, :initial => :issued do 
    event :approve do
      transition :issued => :approved
    end
  end
end
