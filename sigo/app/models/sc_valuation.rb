class ScValuation < ActiveRecord::Base

	state_machine :state, :initial => :disapproved do

    event :approve do
      transition :disapproved => :approved
    end

  end

end
