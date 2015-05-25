class ValuationOfEquipment < ActiveRecord::Base
  belongs_to :subcontract_equipment
  
  state_machine :state, :initial => :disapproved do

    event :approve do
      transition :disapproved => :approved
    end

  end

  def self.get_part_equipment_from_valuation(start_date, end_date, cost_center_id, subcontract_equipment_id, code_equipment)
    mysql_result = ActiveRecord::Base.connection.execute("
      SELECT sed.code, sum(poed.effective_hours), sed.price_no_igv, poed.sector_id,poed.phase_id, poed.working_group_id
      FROM part_of_equipments poe, part_of_equipment_details poed, subcontract_equipment_details sed
      WHERE poe.date BETWEEN '" + start_date.to_s + "' AND '" + end_date.to_s + "'
      AND poe.id=poed.part_of_equipment_id
      AND poe.cost_center_id = " + cost_center_id.to_s + "
      AND poe.equipment_id=sed.id
      AND poe.subcontract_equipment_id = " + subcontract_equipment_id.to_s + "
      AND sed.code LIKE '" + code_equipment.to_s + "'
      GROUP BY sed.code, sed.price_no_igv"
    )
    return mysql_result
  end
  
end
