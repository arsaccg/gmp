class OrderOfService < ActiveRecord::Base
  has_many :order_of_service_details
  has_many :state_per_order_of_services
  belongs_to :cost_center
  belongs_to :entity
  belongs_to :money
  belongs_to :method_of_payment
  belongs_to :user

  accepts_nested_attributes_for :order_of_service_details, :allow_destroy => true

  state_machine :state, :initial => :pre_issued do

    event :issue do
      transition [:pre_issued, :revised] => :issued
    end

    event :observe do
      transition :issued => :pre_issued
    end

    event :revise do
      transition [:issued, :approved] => :revised
    end

    event :approve do
      transition :revised => :approved
    end

    event :cancel do
      transition [:pre_issued, :issued, :revised, :approved] => :canceled
    end
  end

  def self.getOwnArticles(word, name)
    
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
      FROM articles_from_cost_center_" + name.to_s + " a, unit_of_measurements u 
      WHERE (a.code LIKE '05%' || a.code LIKE '04%' || a.code LIKE '03%')
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
      AND a.unit_of_measurement_id = u.id
      GROUP BY a.code
    ")
    return mysql_result
  end

  def self.calculate_total_neto_before_igv(object_calculations, total_before_igv)
    
  end

  def self.calculate_total_neto_after_igv(object_calculations, total_before_igv)
    
  end
end