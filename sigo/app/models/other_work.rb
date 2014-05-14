class OtherWork < ActiveRecord::Base
	belongs_to :certificate
	has_and_belongs_to_many :components
end
