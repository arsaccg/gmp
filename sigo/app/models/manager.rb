class Manager < ActiveRecord::Base
  # Include default devise modules. Others available are:

  #  and :omniauthable, :confirmable,
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :lockable, :timeoutable, :authentication_keys => [:dni]
  attr_accessor :login

  def self.find_first_by_auth_conditions(warden_conditions)
  	
      conditions = warden_conditions.dup
      login = conditions.delete(:login)
      puts "CONDITIONS"
      puts conditions.inspect
      puts "LOGIN"
      puts login.inspect
      #if login = conditions.delete(:login)
      where(conditions).where(["dni = :value ", { :value => conditions[:dni] }]).first
      #else
        #where(conditions).first
      #end
  end

end
