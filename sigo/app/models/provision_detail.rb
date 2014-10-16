class ProvisionDetail < ActiveRecord::Base
	belongs_to :provision, :touch => true
	belongs_to :account_accountant
	has_many :provision_direct_purchase_detail
end
