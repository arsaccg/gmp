class Production::EquipmentReportsController < ApplicationController
	def index
		@company = get_company_cost_center('company')
  	@workingGroups = WorkingGroup.all
    @article = Article.where("type_of_article_id = 3")
    render layout: false
	end

	def complete
		@combo=Array.new
		i=0
		if params[:chosen] == "0"
		elsif params[:chosen] == "specific"
			puts "entra"
			PartOfEquipment.all.each do |part|
				puts "part"
				Article.where("code LIKE '03________' AND code NOT LIKE '0332______'").each do |art|
					if part.equipment_id==art.id 
						@combo << art
					end
				end
			end
		elsif params[:chosen] == "operador" ||  params[:chosen] == "frente"
			pw_id = Array.new
			if params[:chosen] == "operador"
				PositionWorker.where("name LIKE '%operador%'").each do |pw|
					pw_id = pw.id
				end
			else
				PositionWorker.where("name LIKE '%frente%'").each do |pw|
					pw_id = pw.id
				end
			end
			Worker.where("position_worker_id LIKE ?", pw_id).each do |w|
				@combo << { 'id' => w.id.to_i, 'name' => w.first_name + ' '+ w.paternal_surname+' '+w.maternal_surname }
			  i+=1
			end
		elsif params[:chosen] == "equipment"
			Article.where("code LIKE '03________' AND code NOT LIKE '0332______'").each do |art|
				@combo << art
			end
		end
		render json: {:combo => @combo}  
	end

end
