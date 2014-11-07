class Concept < ActiveRecord::Base
  has_many :concept_details
  has_many :concept_valorizations
  has_many :category_of_workers_concepts
  # has_and_belongs_to_many :category_of_workers
end
