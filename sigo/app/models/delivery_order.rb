class DeliveryOrder < ActiveRecord::Base
     
    has_many :state_per_order_details
    has_many :delivery_order_details
    belongs_to :cost_center
    belongs_to :user

    accepts_nested_attributes_for :delivery_order_details, :allow_destroy => true

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
    
    def self.getOwnArticles(word, cost_center_id)
      @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
      @name = @cost_center.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
        FROM articles_from_"+@name+" a, unit_of_measurements u 
        AND (a.code LIKE '04%' || a.code LIKE '03%' || a.code LIKE '02%')
        AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
        AND a.unit_of_measurement_id = u.id
        LIMIT #{display_length}
        OFFSET #{pager_number}
      ")
      return mysql_result
    end
end