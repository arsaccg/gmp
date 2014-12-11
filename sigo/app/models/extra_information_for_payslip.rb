class ExtraInformationForPayslip < ActiveRecord::Base
  belongs_to :worker
  belongs_to :concept
end
