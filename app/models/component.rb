class Component < ActiveRecord::Base
  has_and_belongs_to_many :works
  has_and_belongs_to_many :other_works
end
