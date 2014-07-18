require 'thread'

class AccountAccountant < ActiveRecord::Base
  has_many :provision_details

  def self.import(array_buffer)
    AccountAccountant.import array_buffer
  end
end
