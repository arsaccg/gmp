class ProvisionDetail < ActiveRecord::Base
	belongs_to :provision
	belongs_to :account_accountant
end
