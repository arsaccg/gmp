class OrderOfService < ActiveRecord::Base
  has_many :order_of_service_details
  belongs_to :cost_center
  belongs_to :entity
  belongs_to :method_of_payment
  belongs_to :user

  accepts_nested_attributes_for :order_of_service_details, :allow_destroy => true
end