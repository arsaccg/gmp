class Wbsitem < ActiveRecord::Base
	belongs_to :cost_center
  belongs_to :phase
	has_many :itembywbses

	def self.get_color(amount)
		@color = "#E2EB7F"
		if amount.to_i == 0
			@color="#E8A2A2"
		end
		if amount.to_i>0
			@color="#C0F09C"
		end
		return @color
	end

	def self.get_brief(item_id, budget_id, order)
		str1 = "select sum(ibi.quantity * ibi.price * ib.measured)
		from inputbybudgetanditems as ibi, itembybudgets as ib
		where ibi.cod_input LIKE '"
		#01
		str2 = "%' 
		AND ibi.budget_id = "+budget_id+"
		and ib.budget_id = "+budget_id+"
		AND ibi.`order` LIKE '"+order+"%'
		and ibi.`order` like concat(ib.`order`,'%')"
		#@sum_human = Inputbybudgetanditem.where("cod_input LIKE '01%' AND budget_id = ? AND inputbybudgetanditems.order LIKE ?", budget_id, order + "%").sum("quantity * price")
		@sum_human = ActiveRecord::Base.connection.execute(str1+'01'+str2).first.first
		@sum_materials = ActiveRecord::Base.connection.execute(str1+'02'+str2).first.first
		@sum_tools = ActiveRecord::Base.connection.execute(str1+'03'+str2).first.first
		@sum_subagreements =ActiveRecord::Base.connection.execute(str1+'04'+str2).first.first
		return 	[@sum_human.to_f, @sum_materials.to_f, @sum_tools.to_f, @sum_subagreements.to_f]
	end 

	def self.to_csv(options = {})
		csv = Array.new
		csv << (column_names - ['description', 'notes', 'created_at', 'updated_at', 'project_id', 'start_date', 'end_date', 'predecessors'])
		all.each do |wbsitem|
			csv << wbsitem.attributes.values_at(*column_names)
		end		
	end

	
end
