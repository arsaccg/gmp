class PurchaseOrderExtraCalculation < ActiveRecord::Base
  belongs_to :purchase_order_detail
  belongs_to :extra_calculation
end
