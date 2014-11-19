class DiverseExpensesOfManagement < ActiveRecord::Base
	has_many :diverse_expenses_of_management_details
  accepts_nested_attributes_for :diverse_expenses_of_management_details, :allow_destroy => true
end