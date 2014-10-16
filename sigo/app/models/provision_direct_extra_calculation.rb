class ProvisionDirectExtraCalculation < ActiveRecord::Base
	self.inheritance_column = nil
  belongs_to :provision_detail, :touch => true
  belongs_to :extra_calculation
end
