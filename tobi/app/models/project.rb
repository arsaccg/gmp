class Project < ActiveRecord::Base
	has_many :wbsitems
	has_many :budgets
	has_many :items
	has_many :advances
	has_many :extensionscontrols
  
  def valorizations
    array_valorizations = Array.new
    budgets.each do |budget|
      budget.valorizations.each do |valorization|
        array_valorizations << valorization
      end
    end
    return array_valorizations
  end
end
