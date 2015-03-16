class ConsumptionCost < ActiveRecord::Base
  establish_connection :external

  def self.apply_all_consult
    array_ge = connection.select_one("
      SELECT 
      '-', `general_exp_mo_valoriz`, '-', `general_exp_mo_costreal`, `general_exp_mo_meta` ,
      '-', `general_exp_mat_valoriz`, '-', `general_exp_mat_costreal`,`general_exp_mat_meta` ,
      '-', `general_exp_subcont_valoriz`, '-', `general_exp_subcont_costreal`, `general_exp_subcont_meta` ,
      '-', `general_exp_serv_valoriz`, '-', `general_exp_serv_costreal`, `general_exp_serv_meta` ,
      '-', `general_exp_equip_valoriz`, '-', `general_exp_equip_costreal`, `general_exp_equip_meta` 
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
