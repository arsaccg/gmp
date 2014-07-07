# encoding: UTF-8
class CostCenter < ActiveRecord::Base
	
	has_many :delivery_orders
	has_many :purchase_orders
	has_many :order_of_services
	has_many :entities
	has_many :stock_inputs
	has_many :warehouses
	has_many :center_of_attentions
	has_many :working_groups
	has_many :sectors
	has_many :workers
	has_many :subcontracts
	has_many :subcontract_equipments
	has_many :part_works
	has_many :part_people
	has_many :part_of_equipments

  has_many :items
  has_many :budgets
  
  has_many :wbsitems

	belongs_to :company

	# Access
	has_and_belongs_to_many :users

	default_scope { where(status: "A").order("name ASC") }

	# Validaciones
	include ActiveModel::Validations
	validates :code, :uniqueness => { :scope => [:company_id, :status], :message => "El código debe ser único."}

	after_validation :do_activecreate, on: [:create]
  
    def do_activecreate
      self.status = "A"
    end

  def valorizations
    array_valorizations = Array.new
    budgets.each do |budget|
      budget.valorizations.each do |valorization|
        array_valorizations << valorization
      end
    end
    return array_valorizations
  end

  def self.getWeek(cost_center_id,end_date)
    week_array = ActiveRecord::Base.connection.execute("
      SELECT id,name,start_date,end_date
      FROM weeks_for_cost_center_" + cost_center_id + " 
      WHERE start_date < '" + end_date + "'
    ")    
  end

  def self.getWeek5(cost_center_id,end_date)
    week_array = ActiveRecord::Base.connection.execute("
      SELECT id,name,start_date,end_date
      FROM weeks_for_cost_center_" + cost_center_id.to_s + " 
      WHERE start_date < '" + end_date + "'
      ORDER BY id DESC
    ")    
  end

  def self.getWeek2(cost_center_id,end_date,limit)
    week_array = ActiveRecord::Base.connection.execute("
      SELECT id,name,start_date,end_date
      FROM weeks_for_cost_center_" + cost_center_id + " 
      WHERE start_date > '" + end_date + "'
      LIMIT " + limit.to_s + "
    ")    
  end

  def self.getWeek3(cost_center_id,end_date,limit)
    week_array = ActiveRecord::Base.connection.execute("
      SELECT id,name,start_date,end_date
      FROM weeks_for_cost_center_" + cost_center_id + " 
      WHERE start_date < '" + end_date + "'
      ORDER BY id DESC
      LIMIT " + limit.to_s + "
    ")    
  end
end
