class Concept < ActiveRecord::Base
  has_many :concept_details
  has_many :concept_valorizations
  has_many :category_of_workers_concepts

  accepts_nested_attributes_for :concept_valorizations, :allow_destroy => true
  accepts_nested_attributes_for :concept_details, :allow_destroy => true
  # has_and_belongs_to_many :category_of_workers
end
