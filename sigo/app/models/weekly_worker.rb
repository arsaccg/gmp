class WeeklyWorker < ActiveRecord::Base
	state_machine :state, :initial => :disapproved do

    event :approve do
      transition :disapproved => :approved
    end

  end

  def self.get_name_week_by_dates(first_date, end_date, cost_center_id)
  	name_week = ""

  	mysql_result = ActiveRecord::Base.connection.execute("
      SELECT name
      FROM weeks_for_cost_center_"+cost_center_id.to_s+"
      WHERE start_date = '" + first_date.to_s + "'
      AND end_date = '" + end_date.to_s + "'
    ")

  	mysql_result.each do |date| name_week = date[0]  end

    return name_week
  	
  end
end
