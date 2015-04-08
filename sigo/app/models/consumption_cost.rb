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

  # => Methods for Micro Report
  def self.get_phases_sector_wg  cc_id, date, insertion_date, select, table, condition_id, condition, order, cat
    #AND acc.insertion_date = '" + insertion_date.to_s+ "'
    array_dc = connection.select_all("
      SELECT DISTINCT  " + select.to_s + "
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc " + table.to_s + " 
      WHERE acc." + condition_id.to_s + "
      AND acc.type = '" + cat.to_s + "'
      " + condition.to_s + " 
      ORDER BY " + order.to_s)
    return array_dc
  end

  def self.get_articles  cc_id, date, insertion_date, select, table, condition_id, condition, order, cat
    #AND acc.insertion_date = '" + insertion_date.to_s+ "'
    array_dc = connection.select_all("
      SELECT DISTINCT  " + select.to_s + "
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc " + table.to_s + " 
      WHERE acc." + condition_id.to_s + "
      AND acc.type = '" + cat.to_s + "'
      " + condition.to_s + " 
      ORDER BY " + order.to_s)
    return array_dc
  end  

  def self.get_phases cc_id, date
    array_dc = connection.select_all("
      SELECT DISTINCT  `ph`.`id` 
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc,  `phases` ph
      WHERE acc.phase_id = ph.id
      ORDER BY ph.code")
    return array_dc
  end

  def self.get_sector_from_phases cc_id, date, ph_id
    array_dc = connection.select_all("
      SELECT DISTINCT  `acc`.`sector_id` 
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc,  `sectors` se
      WHERE acc.phase_id = #{ph_id}
      AND acc.sector_id = se.id
      ORDER BY se.code")
    return array_dc
  end     
  
  def self.get_wg_from_sector_from_phases cc_id, date, ph_id, se_id
    array_dc = connection.select_all("
      SELECT DISTINCT  `acc`.`working_group_id` 
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc,  `working_groups` wg
      WHERE acc.working_group_id = wg.id
      AND acc.phase_id = #{ph_id}
      AND acc.sector_id = #{se_id}
      ORDER BY wg.name")
    return array_dc
  end    

  def self.get_articles_from_cwgsf cc_id, date, ph_id, se_id, wg_id
    array_dc = connection.select_all("
      SELECT DISTINCT  Concat(`acc`.`article_code`,' - ',`acc`.`article_name` ,' - ', `acc`.`article_unit`) AS article, SUM(`acc`.`programado_specific_lvl1`) AS programado_specific_lvl1, SUM(`acc`.`meta_specific_lvl_1`) AS meta_specific_lvl_1, SUM(`acc`.`real_specific_lvl_1`) AS real_specific_lvl_1, SUM(`acc`.`valorizado_specific_lvl_1`) AS valorizado_specific_lvl_1, SUM(`acc`.`valor_ganado_specific_lvl_1`) AS valor_ganado_specific_lvl_1
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc
      WHERE acc.working_group_id = #{wg_id}
      AND acc.fase_cod_hijo = #{ph_id}
      AND acc.sector_cod_hijo = #{se_id}
      AND acc.working_group_id = #{wg_id}
      GROUP BY acc.article_code
      ORDER BY acc.article_name")
    return array_dc
  end

  def self.get_articles_from_swgsf cc_id, date, ph_id, se_id
    array_dc = connection.select_all("
      SELECT DISTINCT  Concat(`acc`.`article_code`,' - ',`acc`.`article_name` ,' - ', `acc`.`article_unit`) AS article, SUM(`acc`.`programado_specific_lvl1`) AS programado_specific_lvl1, SUM(`acc`.`meta_specific_lvl_1`) AS meta_specific_lvl_1, SUM(`acc`.`real_specific_lvl_1`) AS real_specific_lvl_1, SUM(`acc`.`valorizado_specific_lvl_1`) AS valorizado_specific_lvl_1, SUM(`acc`.`valor_ganado_specific_lvl_1`) AS valor_ganado_specific_lvl_1
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc
      WHERE acc.fase_cod_hijo = #{ph_id}
      AND acc.sector_cod_hijo = #{se_id}
      AND acc.working_group_id = 0
      GROUP BY acc.article_code
      ORDER BY acc.article_name")
    return array_dc
  end

  def self.get_articles_from_phases cc_id, date, ph_id
    array_dc = connection.select_all("
      SELECT DISTINCT  Concat(`acc`.`article_code`,' - ',`acc`.`article_name` ,' - ', `acc`.`article_unit`) AS article, SUM(`acc`.`programado_specific_lvl1`) AS programado_specific_lvl1, SUM(`acc`.`meta_specific_lvl_1`) AS meta_specific_lvl_1, SUM(`acc`.`real_specific_lvl_1`) AS real_specific_lvl_1, SUM(`acc`.`valorizado_specific_lvl_1`) AS valorizado_specific_lvl_1, SUM(`acc`.`valor_ganado_specific_lvl_1`) AS valor_ganado_specific_lvl_1
      FROM  `actual_values_"+ cc_id.to_s + "_"+ date.to_s + "` acc
      WHERE acc.fase_cod_hijo = #{ph_id}
      AND acc.sector_cod_hijo = 0
      AND acc.working_group_id = 0
      GROUP BY acc.article_code
      ORDER BY acc.article_name")
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

  def self.do_order array_order, table_name
    @treeOrderCD = Tree::TreeNode.new('Costo Directo')
    @treeOrderGG = Tree::TreeNode.new('Gastos Generales')
    @treeOrderSG = Tree::TreeNode.new('Servicios Generales')

    # => Make Tree-Order
    fase_index = array_order.index('fase')
    if !fase_index.nil?
      array_order.insert(fase_index+1, 'fase_cod_hijo')
      array_order[fase_index] = 'fase_cod_padre'
    end
    sector_index = array_order.index('sector')
    if !sector_index.nil?
      array_order.insert(sector_index+1, 'sector_cod_hijo')
      array_order[sector_index] = 'sector_cod_padre'
    end
    article_index = array_order.index('article')
    if !article_index.nil?
      array_order[article_index] = "article_code"
    end
    
    @treeOrderCD = make_tree(@treeOrderCD, array_order, table_name, 'CD')
    @treeOrderGG = make_tree(@treeOrderGG, array_order, table_name, 'GG')
    @treeOrderSG = make_tree(@treeOrderSG, array_order, table_name, 'SG')
    
    return @treeOrderCD, @treeOrderGG, @treeOrderSG
  end

  def self.make_tree obj_tree, array_order, table_name, type
    index = 0
    count_element = array_order.count

    if !array_order[index].nil? && !array_order[index+1].nil?
      sql = "SELECT DISTINCT " + array_order[index].to_s + " FROM " + table_name.to_s + " WHERE type LIKE '" + type.to_s + "' AND " + array_order[index].to_s + " != 'NULL' AND " + array_order[index].to_s + " != '';"
      connection.select_all(sql).each do |row|
        obj_tree << Tree::TreeNode.new(row[array_order[index].to_s].to_s)
        msql = "SELECT DISTINCT " + array_order[index+1].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index].to_s + " = " + row[array_order[index].to_s].to_s + " AND " + array_order[index+1].to_s + " != 'NULL' AND " + array_order[index+1].to_s + " != '';"
        connection.select_all(msql).each do |mrow|
          obj_tree[row[array_order[index].to_s]] << Tree::TreeNode.new(mrow[array_order[index+1].to_s].to_s)
          if !array_order[index+2].nil?
            mssql = "SELECT DISTINCT " + array_order[index+2].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index+1].to_s + " = " + mrow[array_order[index+1].to_s].to_s + " AND " + array_order[index+2].to_s + " != 'NULL' AND " + array_order[index+2].to_s + " != '';"
            connection.select_all(mssql).each do |mmrow|
              obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]] << Tree::TreeNode.new(mmrow[array_order[index+2].to_s].to_s)
              if !array_order[index+3].nil?
                rsql = "SELECT DISTINCT " + array_order[index+3].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index+2].to_s + " = " + mmrow[array_order[index+2].to_s].to_s + " AND " + array_order[index+3].to_s + " != 'NULL' AND " + array_order[index+3].to_s + " != '';"
                connection.select_all(rsql).each do |rrow|
                  obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]] << Tree::TreeNode.new(rrow[array_order[index+3].to_s].to_s)
                  if !array_order[index+4].nil?
                    mrsql = "SELECT DISTINCT " + array_order[index+4].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index+3].to_s + " = " + rrow[array_order[index+3].to_s].to_s + " AND " + array_order[index+4].to_s + " != 'NULL' AND " + array_order[index+4].to_s + " != '';"
                    connection.select_all(mrsql).each do |mrrow|
                      obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]][rrow[array_order[index+3].to_s]] << Tree::TreeNode.new(mrrow[array_order[index+4].to_s].to_s)
                      if !array_order[index+5].nil?
                        rrpsql = "SELECT DISTINCT " + array_order[index+5].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index+4].to_s + " = " + mrrow[array_order[index+4].to_s].to_s + " AND " + array_order[index+5].to_s + " != 'NULL' AND " + array_order[index+5].to_s + " != '';"
                        connection.select_all(rrpsql).each do |rprow|
                          obj_tree[row[array_order[index].to_s]][mrow[array_order[index+1].to_s]][mmrow[array_order[index+2].to_s]][rrow[array_order[index+3].to_s]][mrrow[array_order[index+4].to_s].to_s] << Tree::TreeNode.new(rprow[array_order[index+5].to_s].to_s)
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
      sql = "SELECT " + array_order[index].to_s + " FROM " + table_name.to_s + " WHERE " + array_order[index] + " != 'NULL' AND " + array_order[index] + " != '';"
      ActiveRecord::Base.connection.execute(sql).each do |row|
        obj_tree << Tree::TreeNode.new(row)
      end
    end
    
    return obj_tree
  end

end
