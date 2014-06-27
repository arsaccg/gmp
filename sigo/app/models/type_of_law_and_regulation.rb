class TypeOfLawAndRegulation < ActiveRecord::Base
  has_and_belongs_to_many :law_and_regulations
end