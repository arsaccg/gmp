class ProvisionDirectPurchaseDetail < ActiveRecord::Base
	belongs_to :provision, :touch => true
	belongs_to :account_accountant
end
