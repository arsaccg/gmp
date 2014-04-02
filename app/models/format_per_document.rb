class FormatPerDocument < ActiveRecord::Base
  belongs_to :document
  belongs_to :format
end
