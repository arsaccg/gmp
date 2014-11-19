class ProvisionDirectPurchaseDetail < ActiveRecord::Base
	belongs_to :provision, :touch => true
	belongs_to :account_accountant
	has_many :provision_direct_extra_calculations
	belongs_to :article

	accepts_nested_attributes_for :provision_direct_extra_calculations, :allow_destroy => true	
end
