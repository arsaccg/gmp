class EntityBank < ActiveRecord::Base
  belongs_to :entity
  belongs_to :bank
  belongs_to :money
end
