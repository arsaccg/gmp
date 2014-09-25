class SubcontractAdvance < ActiveRecord::Base
  belongs_to :subcontract, :touch => true
end
