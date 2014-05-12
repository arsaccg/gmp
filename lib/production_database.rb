class ProductionDatabase < ActiveRecord::Base
  establish_connection "remote"
end