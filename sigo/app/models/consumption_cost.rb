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

  def self.apply_all_gen_serv
    array_genser = connection.select_one("
      SELECT 
      '-', '-', '-', `gen_serv_mo_costreal`, `gen_serv_mo_meta` ,
      '-', '-', '-', `gen_serv_mat_costreal`,`gen_serv_mat_meta` ,
      '-', '-', '-', `gen_serv_subcont_costreal`, `gen_serv_subcont_meta` ,
      '-', '-', '-', `gen_serv_service_costreal`, `gen_serv_service_meta` ,
      '-', '-', '-', `gen_serv_equip_costreal`,`gen_serv_equip_meta` 
    FROM `actual_consumption_cost_actual_january`")
    return array_genser
  end
end
