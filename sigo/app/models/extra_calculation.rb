class ExtraCalculation < ActiveRecord::Base
  has_many :order_service_extra_calculations
  has_many :purchase_order_extra_calculations
  has_many :provision_direct_extra_calculation
end
