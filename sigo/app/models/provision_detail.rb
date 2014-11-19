class ProvisionDetail < ActiveRecord::Base
	belongs_to :provision, :touch => true
	belongs_to :account_accountant
	has_many :provision_direct_purchase_detail

  	#accepts_nested_attributes_for :provision_direct_purchase_details, :allow_destroy => true
end
