# enconding: utf-8
class ExchangeOfRate < ActiveRecord::Base
  belongs_to :money
  
  include ActiveModel::Validations
  validates_presence_of :value
	
end