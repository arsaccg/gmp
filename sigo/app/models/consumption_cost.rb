class ConsumptionCost < ActiveRecord::Base
  establish_connection :external

  def self.apply_all_consult
    return connection.select_one("SELECT * FROM actual_consumption_cost_actual_january")
  end
end
