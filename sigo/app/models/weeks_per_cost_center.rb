class WeeksPerCostCenter < ActiveRecord::Base

  def self.get_total_hours_per_week cost_center_id, week_id
    mysql_result = ActiveRecord::Base.connection.execute("SELECT total FROM total_hours_per_week_per_cost_center_" + cost_center_id.to_s + " WHERE status = 1 AND week_id = " + week_id.to_s)
    if mysql_result.count != 0
      return mysql_result.first[0]
    else
      return 48
    end
  end

  def self.get_current_week_by_id cost_center_id
  	return ActiveRecord::Base.connection.execute("SELECT id, name FROM weeks_for_cost_center_1 WHERE start_date >= #{Time.now.strftime('%Y-%m-%d')} AND #{Time.now.strftime('%Y-%m-%d')}  <= end_date AND end_date >= CURRENT_TIMESTAMP LIMIT 1").to_a.first[0]
  end
end
