class Company < ActiveRecord::Base
  has_many :cost_centers

  # Access
  has_and_belongs_to_many :users

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "100x12>"}, :default_url => "/assets/images/avatars/male.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/
	
end
