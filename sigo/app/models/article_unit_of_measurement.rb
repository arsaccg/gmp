class ArticleUnitOfMeasurement < ActiveRecord::Base
	belongs_to :article
	belongs_to :unit_of_measurement
end
