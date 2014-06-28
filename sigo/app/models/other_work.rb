class OtherWork < ActiveRecord::Base
	belongs_to :certificate
	has_and_belongs_to_many :components
	accepts_nested_attributes_for :certificate, :allow_destroy => true
end