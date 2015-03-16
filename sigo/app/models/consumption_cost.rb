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

  def self.create_tables_new_costcenter(cost_center_id)
    puts "Entro aqui"
    create_tables_accumulated_values = connection.execute(
      "CREATE TABLE accumulated_values_" + cost_center_id.to_s + "_until_january
      (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `article_code` varchar(20) NOT NULL,
        `article_name` varchar(500) NOT NULL,
        `article_unit` varchar(40) NOT NULL,
        `programado_specific_lvl1` varchar(255) NOT NULL,
        `meta_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `real_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `valorizado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `valor_ganado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `phase_id` int(11) NOT NULL,
        `sector_id` int(11) NOT NULL,
        `working_group_id` int(11) NOT NULL,
        `measured_meta` varchar(255) NOT NULL,
        PRIMARY KEY (`id`)
      )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
    )
    create_tables_acc_consumption_cost_actual = connection.execute(
      "CREATE TABLE acc_consumption_cost_actual_" + cost_center_id.to_s + "_january
      (
        `direct_cost_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_valoriz` varchar(255) COLLATE utf8_bin NOT NULL
      )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
    )
    create_tables_actual_consumption_cost_actual = connection.execute(
      "CREATE TABLE actual_consumption_cost_actual_" + cost_center_id.to_s + "_january
      (
        `direct_cost_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_equip_meta` varchar(255) COLLATE utf8_bin NOT NULL,  
        `direct_cost_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `direct_cost_serv_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `general_exp_serv_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mo_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_mat_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_equip_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_subcont_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_prog` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_valgan` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_costreal` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_meta` varchar(255) COLLATE utf8_bin NOT NULL,
        `gen_serv_service_valoriz` varchar(255) COLLATE utf8_bin NOT NULL,
        `insertion_date` date DEFAULT NULL
      )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
    )
    create_tables_actual_values = connection.execute(
      "CREATE TABLE actual_values_" + cost_center_id.to_s + "_january
      (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `article_code` varchar(20) NOT NULL,
        `article_name` varchar(500) NOT NULL,
        `article_unit` varchar(40) NOT NULL,
        `programado_specific_lvl1` varchar(255) NOT NULL,
        `meta_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `real_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `valorizado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `valor_ganado_specific_lvl_1` varchar(255) NOT NULL DEFAULT '0',
        `phase_id` int(11) NOT NULL,
        `sector_id` int(11) NOT NULL,
        `working_group_id` int(11) NOT NULL,
        `measured_meta` varchar(255) NOT NULL,
        PRIMARY KEY (`id`)
      )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
    )
  end
end
