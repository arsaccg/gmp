class ConsumptionCost < ActiveRecord::Base
  establish_connection :external

  def self.apply_all_consult
    array_ge = connection.select_one("
      SELECT 
      0, `general_exp_mo_valoriz`, 0, `general_exp_mo_costreal`, `general_exp_mo_meta` ,
      0, `general_exp_mat_valoriz`, 0, `general_exp_mat_costreal`,`general_exp_mat_meta` ,
      0, `general_exp_subcont_valoriz`, 0, `general_exp_subcont_costreal`, `general_exp_subcont_meta` ,
      0, `general_exp_serv_valoriz`, 0, `general_exp_serv_costreal`, `general_exp_serv_meta` ,
      0, `general_exp_equip_valoriz`, 0, `general_exp_equip_costreal`, `general_exp_equip_meta` 
    FROM `actual_consumption_cost_actual_january`")
    return array_ge
  end
end
