class OrderServiceExtraCalculation < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :order_of_service_detail
  belongs_to :extra_calculation
end
