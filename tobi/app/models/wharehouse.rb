class Wharehouse < ActiveRecord::Base
	establish_connection "wharehouses_#{Rails.env}"
end