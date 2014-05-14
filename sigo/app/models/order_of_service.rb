class OrderOfService < ActiveRecord::Base
  has_many :order_of_service_details
  has_many :state_per_order_of_services
  belongs_to :cost_center
  belongs_to :entity
  belongs_to :money
  belongs_to :method_of_payment
  belongs_to :user

  accepts_nested_attributes_for :order_of_service_details, :allow_destroy => true

  state_machine :state, :initial => :pre_issued do

    event :issue do
      transition [:pre_issued, :revised] => :issued
    end

    event :observe do
      transition :issued => :pre_issued
    end

    event :revise do
      transition [:issued, :approved] => :revised
    end

    event :approve do
      transition :revised => :approved
    end

    event :cancel do
      transition [:pre_issued, :issued, :revised, :approved] => :canceled
    end
  end
end