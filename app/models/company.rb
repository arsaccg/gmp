class Company < ActiveRecord::Base
	has_many :cost_centers

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "28x25>"}, :default_url => "/assets/images/avatars/male.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
	
end
