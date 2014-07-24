class Afp < ActiveRecord::Base
	has_many :afp_details
	has_many :worker_afps
end