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
      mysql_result = ActiveRecord::Base.connection.execute("
        SELECT DISTINCT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol
        FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u 
        WHERE b.id = ibi.budget_id
        AND b.type_of_budget =0
        AND b.cost_center_id = #{cost_center_id}
        AND ibi.article_id IS NOT NULL 
        AND ibi.article_id = a.id
        AND (a.code LIKE '04%' || a.code LIKE '03%' || a.code LIKE '02%')
        AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) 
        AND a.unit_of_measurement_id = u.id
      ")

      return mysql_result
    end
end