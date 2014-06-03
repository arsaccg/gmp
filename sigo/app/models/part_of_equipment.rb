class PartOfEquipment < ActiveRecord::Base
	has_many :part_of_equipment_details
	belongs_to :cost_center
	belongs_to :subcontract_equipment
	belongs_to :worker
	accepts_nested_attributes_for :part_of_equipment_details, :allow_destroy => true

	def self.get_workers(subcontract_equip_id, start_date, end_date)
	  return ActiveRecord::Base.connection.execute("SELECT DISTINCT wo.id, CONCAT( wo.first_name,  ' ', wo.second_name,  ' ', wo.paternal_surname,  ' ', wo.maternal_surname ) as 'worker'
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,subcontract_equipment_details sced 
      WHERE sced.code IN(" + subcontract_equip_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.worker_id=wo.id 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id")
	end

	def self.get_report_per_worker(subcontract_equip_id, start_date, end_date, worker_id)
	  return ActiveRecord::Base.connection.execute("SELECT pha.id, pha.name, SUM(poed.effective_hours), SUM(poe.fuel_amount), ROUND( ( SUM(poe.fuel_amount) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
      WHERE sced.code IN(" + subcontract_equip_id + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.worker_id=wo.id 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND poed.phase_id=pha.id
      AND wo.id = " + worker_id.to_s + "
      GROUP BY pha.name
      ")
	end

  def self.get_equipments(worker_id, start_date, end_date)
    return ActiveRecord::Base.connection.execute("SELECT DISTINCT sced.code, art.name as 'article'
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,subcontract_equipment_details sced, articles art 
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "' 
      AND poe.worker_id IN(" + worker_id + ") 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND sced.article_id = art.id")
  end

  def self.get_report_per_equipments(subcontract_equip_id, start_date, end_date, worker_id)
    return ActiveRecord::Base.connection.execute("SELECT pha.id, pha.name, SUM(poed.effective_hours), SUM(poe.fuel_amount), ROUND( ( SUM(poe.fuel_amount) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
      WHERE sced.code IN(" + worker_id.to_s + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.worker_id=wo.id 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND poed.phase_id=pha.id
      AND wo.id = " + subcontract_equip_id + "
      GROUP BY pha.name
      ")
  end

  def self.get_equipments_per_sector(sector_id, start_date, end_date)
    return ActiveRecord::Base.connection.execute("SELECT DISTINCT sced.code, art.name as 'article'
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,subcontract_equipment_details sced, articles art 
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "' 
      AND poed.sector_id IN(" + sector_id + ") 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND sced.article_id = art.id")
  end

  def self.get_report_per_equipments_per_sector(subcontract_equip_id, start_date, end_date, worker_id)
    return ActiveRecord::Base.connection.execute("SELECT pha.id, pha.name, SUM(poed.effective_hours), SUM(poe.fuel_amount), ROUND( ( SUM(poe.fuel_amount) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
      WHERE sced.code IN(" + worker_id.to_s + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.worker_id=wo.id 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND poed.phase_id=pha.id
      AND poed.sector_id = " + subcontract_equip_id + "
      GROUP BY pha.name
      ")
  end

  def self.get_equipments_per_article(art_id, start_date, end_date)
    return ActiveRecord::Base.connection.execute("SELECT DISTINCT sced.code, art.name as 'article'
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,subcontract_equipment_details sced, articles art 
      WHERE poe.date BETWEEN '" + start_date + "' AND '" + end_date + "' 
      AND poe.equipment_id IN(" + art_id + ") 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND sced.article_id = art.id")
  end

  def self.get_report_per_equipments_per_article(subcontract_equip_id, start_date, end_date, worker_id)
    return ActiveRecord::Base.connection.execute("SELECT pha.id, pha.name, SUM(poed.effective_hours), SUM(poe.fuel_amount), ROUND( ( SUM(poe.fuel_amount) / SUM(poed.effective_hours) ), 2)
      FROM part_of_equipments poe, workers wo, part_of_equipment_details poed,phases pha,subcontract_equipment_details sced 
      WHERE sced.code IN(" + worker_id.to_s + ") 
      AND poe.date BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND poe.worker_id=wo.id 
      AND poe.equipment_id=sced.article_id 
      AND poe.id=poed.part_of_equipment_id 
      AND poe.subcontract_equipment_id=sced.subcontract_equipment_id 
      AND poed.phase_id=pha.id
      AND poe.equipment_id = " + subcontract_equip_id + "
      GROUP BY pha.name
      ")
  end

  def self.getOwnFuelArticles(word, cost_center_id)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT DISTINCT a.id, a.name
      FROM inputbybudgetanditems ibi, budgets b, articles a, unit_of_measurements u 
      WHERE b.id = ibi.budget_id
      AND b.type_of_budget =0
      AND b.cost_center_id = #{cost_center_id}
      AND ibi.article_id IS NOT NULL 
      AND ibi.article_id = a.id
      AND a.code LIKE '__32%'
      AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' )
    ")

    return mysql_result
  end
end