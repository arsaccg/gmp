class StatePerWarehouseOrder < ActiveRecord::Base
  belongs_to :warehouse_order
  belongs_to :user
end