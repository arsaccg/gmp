class WeeksPerCostCenter < ActiveRecord::Base

  def self.get_total_hours_per_week cost_center_id, week_id
    mysql_result = ActiveRecord::Base.connection.execute("SELECT total FROM total_hours_per_week_per_cost_center_" + cost_center_id.to_s + " WHERE status = 1 AND week_id = " + week_id.to_s)
    if mysql_result.count != 0
      return mysql_result.first[0]
    else
      return 48
    end
  end
end
