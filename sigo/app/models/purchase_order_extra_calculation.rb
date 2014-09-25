class PurchaseOrderExtraCalculation < ActiveRecord::Base
  self.inheritance_column = nil
  belongs_to :purchase_order_detail, :touch => true
  belongs_to :extra_calculation
end
