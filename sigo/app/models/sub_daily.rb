require 'thread'

class SubDaily < ActiveRecord::Base

  def self.import(array_buffer)
    SubDaily.import array_buffer
  end
  
end
