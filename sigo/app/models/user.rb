class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  has_many :deliver_orders
  has_many :state_per_order_details
  has_many :purchase_orders
  has_many :state_per_order_purchases
  has_many :order_of_services
  has_many :state_per_order_of_services

  # Access
  has_and_belongs_to_many :cost_centers
  has_and_belongs_to_many :companies

  has_attached_file :avatar, :styles => { :medium => "300x300>", :thumb => "28x25>" }, :default_url => "/assets/images/avatars/male.png"
  validates_attachment_content_type :avatar, :content_type => /\Aimage\/.*\Z/

  include RoleModel
  roles_attribute :roles_mask
  roles :director, :approver, :reviser, :issuer, :canceller

  # Director = Can create CIA and Users
  # Anuler = Can cancel orders
  # Approver = Can approve orders (Aprobado)
  # Reviser = Can give approval (Visto Bueno)
  # Issuer = Can issue orders (Emitido)
  
end 