class Provision < ActiveRecord::Base
	belongs_to :cost_center
	belongs_to :document_provision
	has_many :provision_details

	accepts_nested_attributes_for :provision_details, :allow_destroy => true
end
