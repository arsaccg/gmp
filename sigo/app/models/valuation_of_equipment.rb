class ValuationOfEquipment < ActiveRecord::Base
  belongs_to :subcontract_equipment
  
  state_machine :state, :initial => :disapproved do

    event :approve do
      transition :disapproved => :approved
    end

  end
  
end
