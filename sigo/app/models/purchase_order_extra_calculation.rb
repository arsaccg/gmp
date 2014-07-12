class PurchaseOrderExtraCalculation < ActiveRecord::Base
  belongs_to :purchase_order_detail
end
