class ConsumptionCost < ActiveRecord::Base
  establish_connection :external

  def execute_bi_values
    @iteractions = Array.new
    CostCenter.select(:id).select(:start_date).select(:end_date).each do |costCenter|
      cost_center_id, start_date, end_date = costCenter.id, costCenter.start_date, costCenter.end_date
      if !end_date.nil?
        start_date.upto(end_date) do |a|
          start_date_month = Date.new(a.year.to_s, a.month.to_s, 1).strftime('%Y-%m-%d')
          end_date_month = Date.new(a.year.to_s, a.month.to_s, 1).next_month.prev_day.strftime('%Y-%m-%d')
          @iteractions << [cost_center_id, start_date_month, end_date_month]
        end
      elsif end_date.nil?
        start_date.upto(Date.parse(Time.now.strftime('%Y-%m-%d'))) do |a|
          start_date_month = Date.new(a.year.to_s, a.month.to_s, 1).strftime('%Y-%m-%d')
          end_date_month = Date.new(a.year.to_s, a.month.to_s, 1).next_month.prev_day.strftime('%Y-%m-%d')
          @iteractions << [cost_center_id, start_date_month, end_date_month]
        end
      end
      @iteractions = @iteractions.uniq
      @iteractions.each do |i|
        sql_macro = "CALL SHOWME_MACRO_VALUES_BI(" + i[0].to_s + ", " + i[1].to_s + ", " + i[2].to_s + ")"
        sql_micro = "CALL SHOWME_MICRO_VALUES_BI(" + i[0].to_s + ", " + i[1].to_s + ", " + i[2].to_s + ")"
        ActiveRecord::Base.connection.execute(sql_macro)
        ActiveRecord::Base.connection.execute(sql_micro)
      end
    end
  end

  # => Methods for Macro Report

  def self.apply_all_general_expenses cc_id, date
    array_ge = connection.select_one("
      SELECT 
      '-', `general_exp_mo_valoriz`, '-', `general_exp_mo_costreal`, `general_exp_mo_meta` ,
      '-', `general_exp_mat_valoriz`, '-', `general_exp_mat_costreal`,`general_exp_mat_meta` ,
      '-', `general_exp_subcont_valoriz`, '-', `general_exp_subcont_costreal`, `general_exp_subcont_meta` ,
      '-', `general_exp_serv_valoriz`, '-', `general_exp_serv_costreal`, `general_exp_serv_meta` ,
      '-', `general_exp_equip_valoriz`, '-', `general_exp_equip_costreal`, `general_exp_equip_meta`,
      (`general_exp_mo_costreal` + `general_exp_mat_costreal` + `general_exp_subcont_costreal` + `general_exp_serv_costreal` + `general_exp_equip_costreal`) as `sum_costo_real`,
      (`general_exp_mo_meta` + `general_exp_mat_meta` + `general_exp_subcont_meta` + `general_exp_serv_meta` + `general_exp_equip_meta`) as `sum_meta`
    FROM `actual_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_ge
  end

  def self.apply_all_general_services cc_id, date
    array_genser = connection.select_one("
      SELECT 
      '-', '-', '-', `gen_serv_mo_costreal`, `gen_serv_mo_meta` ,
      '-', '-', '-', `gen_serv_mat_costreal`,`gen_serv_mat_meta` ,
      '-', '-', '-', `gen_serv_subcont_costreal`, `gen_serv_subcont_meta` ,
      '-', '-', '-', `gen_serv_service_costreal`, `gen_serv_service_meta` ,
      '-', '-', '-', `gen_serv_equip_costreal`,`gen_serv_equip_meta`,
      (`gen_serv_mo_costreal` + `gen_serv_mat_costreal` + `gen_serv_subcont_costreal` + `gen_serv_service_costreal` + `gen_serv_equip_costreal`) as `sum_costo_real`,
      (`gen_serv_mo_meta` + `gen_serv_mat_meta` + `gen_serv_subcont_meta` + `gen_serv_service_meta` + `gen_serv_equip_meta`) as `sum_meta`
    FROM `actual_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_genser
  end

  def self.apply_all_direct_cost cc_id, date
    array_dc = connection.select_one("
      SELECT 
      `direct_cost_mo_prog`, `direct_cost_mo_valoriz`, `direct_cost_mo_valgan`, `direct_cost_mo_costreal`, `direct_cost_mo_meta` ,
      `direct_cost_mat_prog`, `direct_cost_mat_valoriz`, `direct_cost_mat_valgan`, `direct_cost_mat_costreal`, `direct_cost_mat_meta` ,
      `direct_cost_subcont_prog`, `direct_cost_subcont_valoriz`, `direct_cost_subcont_valgan`, `direct_cost_subcont_costreal`, `direct_cost_subcont_meta`,
      `direct_cost_serv_prog`, `direct_cost_serv_valoriz`, `direct_cost_serv_valgan`, `direct_cost_serv_costreal`, `direct_cost_serv_meta`,
      `direct_cost_equip_prog`, `direct_cost_equip_valoriz`, `direct_cost_equip_valgan`, `direct_cost_equip_costreal`, `direct_cost_equip_meta`, 
      (`direct_cost_mo_prog` + `direct_cost_mat_prog` + `direct_cost_subcont_prog` + `direct_cost_serv_prog` + `direct_cost_equip_prog`) as `sum_programado`,
      (`direct_cost_mo_valoriz` + `direct_cost_mat_valoriz` + `direct_cost_subcont_valoriz` + `direct_cost_serv_valoriz` + `direct_cost_equip_valoriz`) as `sum_valorizado`,
      (`direct_cost_mo_valgan` + `direct_cost_mat_valgan` + `direct_cost_subcont_valgan` + `direct_cost_serv_valgan` + `direct_cost_equip_valgan`) as `sum_valorganado`,
      (`direct_cost_mo_costreal` + `direct_cost_mat_costreal` + `direct_cost_subcont_costreal` + `direct_cost_serv_costreal` + `direct_cost_equip_costreal`) as `sum_costo_real`,
      (`direct_cost_mo_meta` + `direct_cost_mat_meta` + `direct_cost_subcont_meta` + `direct_cost_serv_meta` + `direct_cost_equip_meta`) as `sum_meta`
    FROM `actual_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_dc
  end

  def self.apply_all_accumulated_general_expenses cc_id, date
    array_ge = connection.select_one("
      SELECT 
      '-', `general_exp_mo_valoriz`, '-', `general_exp_mo_costreal`, `general_exp_mo_meta` ,
      '-', `general_exp_mat_valoriz`, '-', `general_exp_mat_costreal`,`general_exp_mat_meta` ,
      '-', `general_exp_subcont_valoriz`, '-', `general_exp_subcont_costreal`, `general_exp_subcont_meta` ,
      '-', `general_exp_serv_valoriz`, '-', `general_exp_serv_costreal`, `general_exp_serv_meta` ,
      '-', `general_exp_equip_valoriz`, '-', `general_exp_equip_costreal`, `general_exp_equip_meta`,
      (`general_exp_mo_costreal` + `general_exp_mat_costreal` + `general_exp_subcont_costreal` + `general_exp_serv_costreal` + `general_exp_equip_costreal`) as `sum_costo_real`,
      (`general_exp_mo_meta` + `general_exp_mat_meta` + `general_exp_subcont_meta` + `general_exp_serv_meta` + `general_exp_equip_meta`) as `sum_meta`
    FROM `acc_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_ge
  end

  def self.apply_all_accumulated_general_services cc_id, date
    array_genser = connection.select_one("
      SELECT 
      '-', '-', '-', `gen_serv_mo_costreal`, `gen_serv_mo_meta`,
      '-', '-', '-', `gen_serv_mat_costreal`, `gen_serv_mat_meta`,
      '-', '-', '-', `gen_serv_subcont_costreal`, `gen_serv_subcont_meta`,
      '-', '-', '-', `gen_serv_service_costreal`, `gen_serv_service_meta`,
      '-', '-', '-', `gen_serv_equip_costreal`,`gen_serv_equip_meta`,
      (`gen_serv_mo_costreal` + `gen_serv_mat_costreal` + `gen_serv_subcont_costreal` + `gen_serv_service_costreal` + `gen_serv_equip_costreal`) as `sum_costo_real`,
      (`gen_serv_mo_meta` + `gen_serv_mat_meta` + `gen_serv_subcont_meta` + `gen_serv_service_meta` + `gen_serv_equip_meta`) as `sum_meta`
    FROM `acc_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_genser
  end

  def self.apply_all_accumulated_direct_cost cc_id, date
    array_dc = connection.select_one("
      SELECT 
      `direct_cost_mo_prog`, `direct_cost_mo_valoriz`, `direct_cost_mo_valgan`, `direct_cost_mo_costreal`, `direct_cost_mo_meta` ,
      `direct_cost_mat_prog`, `direct_cost_mat_valoriz`, `direct_cost_mat_valgan`, `direct_cost_mat_costreal`, `direct_cost_mat_meta` ,
      `direct_cost_subcont_prog`, `direct_cost_subcont_valoriz`, `direct_cost_subcont_valgan`, `direct_cost_subcont_costreal`, `direct_cost_subcont_meta` ,
      `direct_cost_serv_prog`, `direct_cost_serv_valoriz`, `direct_cost_serv_valgan`, `direct_cost_serv_costreal`, `direct_cost_serv_meta` ,
      `direct_cost_equip_prog`, `direct_cost_equip_valoriz`, `direct_cost_equip_valgan`, `direct_cost_equip_costreal`, `direct_cost_equip_meta`,
      (`direct_cost_mo_prog` + `direct_cost_mat_prog` + `direct_cost_subcont_prog` + `direct_cost_serv_prog` + `direct_cost_equip_prog`) as `sum_programado`,
      (`direct_cost_mo_valoriz` + `direct_cost_mat_valoriz` + `direct_cost_subcont_valoriz` + `direct_cost_serv_valoriz` + `direct_cost_equip_valoriz`) as `sum_valorizado`,
      (`direct_cost_mo_valgan` + `direct_cost_mat_valgan` + `direct_cost_subcont_valgan` + `direct_cost_serv_valgan` + `direct_cost_equip_valgan`) as `sum_valorganado`,
      (`direct_cost_mo_costreal` + `direct_cost_mat_costreal` + `direct_cost_subcont_costreal` + `direct_cost_serv_costreal` + `direct_cost_equip_costreal`) as `sum_costo_real`,
      (`direct_cost_mo_meta` + `direct_cost_mat_meta` + `direct_cost_subcont_meta` + `direct_cost_serv_meta` + `direct_cost_equip_meta`) as `sum_meta`
    FROM `acc_consumption_cost_actual_"+ cc_id.to_s + "_"+ date.to_s + "`")
    return array_dc
  end

  def self.create_tables_new_costcenter(cost_center_id,start_date,end_date)
    start_date = "2015-01-01".to_date
    end_date = "2020-03-31".to_date
    number = 0
    while (start_date.month <= end_date.month && start_date.year <= end_date.year) do
      create_tables_accumulated_values = connection.execute(
        "CREATE TABLE accumulated_values_" + cost_center_id.to_s + "_until_"+start_date.month.to_s.rjust(2,'0')+start_date.year.to_s.rjust(4,'0')+"
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
          `amount` varchar(255) NOT NULL,
          `insertion_date` date DEFAULT NULL,
          PRIMARY KEY (`id`)
        )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
      )
      create_tables_acc_consumption_cost_actual = connection.execute(
        "CREATE TABLE acc_consumption_cost_actual_" + cost_center_id.to_s + "_"+start_date.month.to_s.rjust(2,'0')+start_date.year.to_s.rjust(4,'0')+"
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
      create_tables_actual_consumption_cost_actual = connection.execute(
        "CREATE TABLE actual_consumption_cost_actual_" + cost_center_id.to_s + "_"+start_date.month.to_s.rjust(2,'0')+start_date.year.to_s.rjust(4,'0')+"
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
        "CREATE TABLE actual_values_" + cost_center_id.to_s + "_"+start_date.month.to_s.rjust(2,'0')+start_date.year.to_s.rjust(4,'0')+"
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
          `insertion_date` date DEFAULT NULL,
          PRIMARY KEY (`id`)
        )ENGINE=MyISAM  DEFAULT CHARSET=latin1 AUTO_INCREMENT=15 ;"
      )
      start_date = start_date + 1.month
    end
  end

  def self.do_order array_order, table_name, array_columns_delivered, array_columns_prev_delivered
    @treeOrderCD = Tree::TreeNode.new('Costo Directo')
    @treeOrderGG = Tree::TreeNode.new('Gastos Generales')
    @treeOrderSG = Tree::TreeNode.new('Servicios Generales')
    array_extras_columns = Array.new

    # => Make columns for select
    array_columns_delivered = array_columns_delivered.join(',')
    array_columns_prev_delivered = array_columns_prev_delivered.join(',')

    # => Make Tree-Order
    fase_index = array_order.index('fase')
    if !fase_index.nil?
      array_order.insert(fase_index+1, 'fase_cod_hijo')
      array_order[fase_index] = 'fase_cod_padre'
      array_extras_columns << "CONCAT('(',fase_cod_padre,') ',fase_cod_padre_nombre) AS str_fase_padre"
      array_extras_columns << "CONCAT('(',fase_cod_hijo,') ',fase_cod_hijo_nombre) AS str_fase_hijo"
    end
    sector_index = array_order.index('sector')
    if !sector_index.nil?
      array_order.insert(sector_index+1, 'sector_cod_hijo')
      array_order[sector_index] = 'sector_cod_padre'
      array_extras_columns << "CONCAT('(',sector_cod_padre,') ',sector_cod_padre_nombre) AS str_sector_padre"
      array_extras_columns << "CONCAT('(',sector_cod_hijo,') ',sector_cod_hijo_nombre) AS str_sector_hijo"
    end
    article_index = array_order.index('article')
    if !article_index.nil?
      array_order[article_index] = "article_code"
      array_extras_columns << "CONCAT('(',article_code,') ',article_name,' - ', article_unit) AS str_article , " + array_columns_delivered
    end
    array_extras_columns << "working_group_id AS working_group"
    
    @treeOrderCD = make_tree(@treeOrderCD, array_order, table_name, 'CD', array_extras_columns, array_columns_delivered)
    @treeOrderGG = make_tree(@treeOrderGG, array_order, table_name, 'GG', array_extras_columns, array_columns_delivered)
    @treeOrderSG = make_tree(@treeOrderSG, array_order, table_name, 'SG', array_extras_columns, array_columns_delivered)

    return @treeOrderCD, @treeOrderGG, @treeOrderSG
  end

  def self.make_tree obj_tree, array_order, table_name, type, array_extras_columns, array_columns_delivered
    index = 0
    count_element = array_order.count

    if !array_order[index].nil? && !array_order[index+1].nil?
      sql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index])}]
      sql = "SELECT DISTINCT " + array_order[index].to_s + ',' + sql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index].to_s + " != 'NULL' AND " + array_order[index].to_s + " != '';"
      connection.select_all(sql).each do |row|
        obj_tree << Tree::TreeNode.new(row[array_order[index].to_s].to_s, row[sql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
        msql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index+1])}]
        msql = "SELECT DISTINCT " + array_order[index+1].to_s + ',' + msql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index].to_s + " = " + row[array_order[index].to_s].to_s + " AND " + array_order[index+1].to_s + " != 'NULL' AND " + array_order[index+1].to_s + " != '';"
        connection.select_all(msql).each do |mrow|
          obj_tree[row[array_order[index].to_s]] << Tree::TreeNode.new(mrow[array_order[index+1].to_s].to_s, mrow[msql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
          if !array_order[index+2].nil?
            mssql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index+2])}]
            mssql = "SELECT DISTINCT " + array_order[index+2].to_s + ',' + mssql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index+1].to_s + " = " + mrow[array_order[index+1].to_s].to_s + " AND " + array_order[index+2].to_s + " != 'NULL' AND " + array_order[index+2].to_s + " != '';"
            connection.select_all(mssql).each do |mmrow|
              obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]] << Tree::TreeNode.new(mmrow[array_order[index+2].to_s].to_s, mmrow[mssql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
              if !array_order[index+3].nil?
                rsql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index+3])}]
                rsql = "SELECT DISTINCT " + array_order[index+3].to_s + ',' + rsql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index+2].to_s + " = " + mmrow[array_order[index+2].to_s].to_s + " AND " + array_order[index+3].to_s + " != 'NULL' AND " + array_order[index+3].to_s + " != '';"
                connection.select_all(rsql).each do |rrow|
                  obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]] << Tree::TreeNode.new(rrow[array_order[index+3].to_s].to_s, rrow[rsql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
                  if !array_order[index+4].nil?
                    mrsql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index+4])}]
                    mrsql = "SELECT DISTINCT " + array_order[index+4].to_s + ',' + mrsql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index+3].to_s + " = " + rrow[array_order[index+3].to_s].to_s + " AND " + array_order[index+4].to_s + " != 'NULL' AND " + array_order[index+4].to_s + " != '';"
                    connection.select_all(mrsql).each do |mrrow|
                      obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]][rrow[array_order[index+3].to_s]] << Tree::TreeNode.new(mrrow[array_order[index+4].to_s].to_s, mrrow[mrsql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
                      if !array_order[index+5].nil?
                        rrpsql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index+5])}]
                        rrpsql = "SELECT DISTINCT " + array_order[index+5].to_s + ',' + rrpsql_data.to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index+4].to_s + " = " + mrrow[array_order[index+4].to_s].to_s + " AND " + array_order[index+5].to_s + " != 'NULL' AND " + array_order[index+5].to_s + " != '';"
                        connection.select_all(rrpsql).each do |rprow|
                          obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]][rrow[array_order[index+3].to_s]][mrrow[array_order[index+4].to_s].to_s] << Tree::TreeNode.new(rprow[array_order[index+5].to_s].to_s, rprow[rrpsql_data.split("AS").map{|s| s.delete(' ')}[1].to_s].to_s)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    elsif !array_order[index].nil?
      sql_data = array_extras_columns[array_extras_columns.index{|s| s.include?(array_order[index])}]
      sql = "SELECT " + array_order[index].to_s + ',' + sql_data.to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index] + " != 'NULL' AND " + array_order[index] + " != '';"
      ActiveRecord::Base.connection.execute(sql).each do |row|
        obj_tree << Tree::TreeNode.new(row[array_order[index].to_s].to_s, row[sql_data.to_s].to_s)
      end
    end

    return obj_tree
  end

end
