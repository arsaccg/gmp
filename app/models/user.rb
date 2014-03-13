class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :deliver_orders
  has_many :state_per_order_details

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "28x25>" }, :default_url => "/assets/images/avatars/male.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  include RoleModel
  roles_attribute :roles_mask
  roles :director, :editor, :approver, :reviser
  # Director = Can create CIA and Users (1)
  # Editor = Can edit orders (2)
  # Approver = Can approve orders (Aprobado) (4)
  # Reviser = Can give approval (Visto Bueno) (8)

end 
