class Reports::ConsumptioncostsController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  

  def index
    @dates = Array.new
    @mssg_error = nil
    cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    start_date = cost_center.start_date
    end_date = cost_center.end_date
    # start_date = cost_center_detail_obj.start_date_of_work
    # end_date = start_date + cost_center_detail_obj.execution_term.days
    if !start_date.nil?
      if !end_date.nil?
        start_date.upto(end_date) do |a|
          @dates << [a.month, a.year]
        end
      else
        start_date.upto(Date.parse(Time.now.strftime('%Y-%m-%d'))) do |a|
          @dates << [a.month, a.year]
        end
      end
      @dates.uniq!

      # => Config
      @phase = Phase.select(:id).select(:name).select(:code).where("code LIKE '__'")

      @sector = Sector.select(:id).select(:name).select(:code).where("code LIKE '__'")
      @cc = get_company_cost_center("cost_center")
      @working_group = WorkingGroup.select(:id).select(:name)
      front_chief_ids = WorkingGroup.distinct.select(:front_chief_id).where("cost_center_id ="+@cc.to_s).map(&:front_chief_id)
      @front_chiefs = Worker.distinct.where(:id => front_chief_ids) # Jefes de Frentes
      # PositionWorker.find(1).workers
      master_builder_ids = WorkingGroup.distinct.select(:master_builder_id).where("cost_center_id ="+@cc.to_s).map(&:master_builder_id)
      @master_builders = Worker.distinct.where(:id => master_builder_ids) # Capatazes o Maestros de Obra
      # PositionWorker.find(2).workers
      executor_ids = Subcontract.distinct.select(:entity_id).where('entity_id <> 0').where("cost_center_id ="+@cc.to_s).map(&:entity_id)
      @executors = Entity.distinct.where(:id => executor_ids) # Exclude the Subcontract Default

      @groups = Category.select(:id).select(:name).select(:code).where("code LIKE '__'")
    else
      @mssg_error = "Para el centro de costo " + cost_center.name + " no esta definida una fecha de inicio. Por favor ingresar antes de continuar."
    end

    render layout: false
  end

  def consult
    @mssg_error = nil
    @month = Date.parse(params[:date] + '-01').strftime('%B %Y')
    month = Date.parse(params[:date] + '-01').strftime('%m%Y')
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))

  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	@magic_result_ge = ConsumptionCost.apply_all_general_expenses(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH
    @magic_result_gen_serv = ConsumptionCost.apply_all_general_services(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH
    @magic_result_dc = ConsumptionCost.apply_all_direct_cost(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH

    @accumulated_result_ge = ConsumptionCost.apply_all_accumulated_general_expenses(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH
    @accumulated_result_gen_serv = ConsumptionCost.apply_all_accumulated_general_services(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH
    @accumulated_result_dc = ConsumptionCost.apply_all_accumulated_direct_cost(cost_center_obj.id, month) rescue nil # => MODIFICAR A MONTH

    if (@magic_result_ge != nil && @magic_result_gen_serv != nil && @magic_result_dc != nil) && (@accumulated_result_ge != nil && @accumulated_result_gen_serv != nil && @accumulated_result_dc != nil)
      @costo_total_programado = @magic_result_dc['sum_programado'].to_f
      @costo_total_valorizado = @magic_result_dc['sum_valorizado'].to_f # => FALTA SUMARLES el valorizado de Gastos Generales
      @costo_total_valor_ganado = @magic_result_dc['sum_valorganado'].to_f
      @costo_total_costo_real = @magic_result_dc['sum_costo_real'].to_f + @magic_result_ge['sum_costo_real'].to_f + @magic_result_gen_serv['sum_costo_real'].to_f
      @costo_total_meta = @magic_result_dc['sum_meta'].to_f + @magic_result_ge['sum_meta'].to_f + @magic_result_gen_serv['sum_meta'].to_f
      @costo_total_accumulado_programado = @accumulated_result_dc['sum_programado'].to_f
      @costo_total_accumulado_valorizado = @accumulated_result_dc['sum_valorizado'].to_f # => FALTA el valorizado de Gastos Generales
      @costo_total_accumulado_valor_ganado = @accumulated_result_dc['sum_valorganado'].to_f
      @costo_total_accumulado_costo_real = @accumulated_result_dc['sum_costo_real'].to_f + @accumulated_result_ge['sum_costo_real'].to_f + @accumulated_result_gen_serv['sum_costo_real'].to_f
      @costo_total_accumulado_meta = @accumulated_result_dc['sum_meta'].to_f + @accumulated_result_ge['sum_meta'].to_f + @accumulated_result_gen_serv['sum_meta'].to_f
    else
      @mssg_error = "No estan completos los datos para hacer la consulta en la fecha seleccionada."
    end

    render(partial: 'table', :layout => false)
  end

  def create_tables_missing
    cost_centers = CostCenter.all
    cost_centers.each do |cc|
      create_tables = ConsumptionCost.create_tables_new_costcenter(cc.id,cc.start_date,cc.end_date)
    end
    flash[:notice] = "Se han creado las tablas de los centros de costo."
    redirect_to :action => :index
  end

  def get_subphase
    type = Phase.where("id IN (" + params[:phase_id].to_a.join(',').to_s + ")")
    cad = Array.new
    type.each do |ph|
      cad << "code LIKE '" + ph.code.to_s + "__'"
    end
    subphase = Phase.where("( " + cad.to_a.join(' OR ').to_s + ")")
    render json: {:subphase => subphase}  
  end

  def get_subsector
    type = Sector.where("id IN (" + params[:sector_id].to_a.join(',').to_s + ")")
    cad = Array.new
    type.each do |ph|
      cad << "code LIKE '" + ph.code.to_s + "__'"
    end    
    subsector = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND (" + cad.to_a.join(' OR ').to_s + ")" )
    render json: {:subsector => subsector}  
  end

  def get_subgroup
    type = Category.where("id IN (" + params[:group_id].to_a.join(',').to_s + ")")
    cad = Array.new
    type.each do |ph|
      cad << "code LIKE '" + ph.code.to_s + "__'"
    end      
    subgroup = Category.where(" ( " + cad.to_a.join(' OR ').to_s + ") ")
    render json: {:subgroup => subgroup}  
  end

  def get_specific
    type = Category.where("id IN (" + params[:subgroup_id].to_a.join(',').to_s + ")")
    cad = Array.new
    type.each do |ph|
      cad << "code LIKE '" + ph.code.to_s + "__'"
    end     
    specific = Category.where(" ( " + cad.to_a.join(' OR ').to_s + ") ")
    render json: {:specific => specific}  
  end

  def get_art
    type = Category.where("id IN (" + params[:specific_id].to_a.join(',').to_s + ")")
    cad = Array.new
    type.each do |ph|
      cad << "code LIKE '__" + ph.code.to_s + "__'"
    end      
    article = Article.where(" ( " + cad.to_a.join(' OR ').to_s + ") ")
    render json: {:article => article}  
  end 

  def consult_with_config_2
    @month = Date.parse(params[:date] + '-01').strftime('%m-%Y')
    month = Date.parse(params[:date] + '-01').strftime('%m%Y')
    prev_month = (Date.parse(params[:date] + '-01') - 1.month).strftime('%m%Y')
    cost_center_id = get_company_cost_center('cost_center')
    table_name = "actual_values_" + cost_center_id.to_s + '_' + month
    array_order_filters = Array.new
    array_values_viewed = Array.new
    array_values_viewed = params[:values_viewed]

    if params[:subphase]!=""
      array_order_filters << " AND fase_cod_hijo IN (" + Phase.where( :id => params[:subphase] ).map(&:code).join(',').to_s + ")"
    elsif params[:phase]!=""
      array_order_filters << " AND fase_cod_padre IN (" + Phase.where( :id => params[:phase] ).map(&:code).join(',') + ")"
    end
    if params[:subsector]!=""
      array_order_filters << " AND sector_cod_hijo IN (" + Sector.where( :id => params[:subsector] ).map(&:code).join(',').to_s + ")"
    elsif params[:sector]!=""
      array_order_filters << " AND sector_cod_padre IN (" + Sector.where( :id => params[:sector] ).map(&:code).join(',').to_s + ")"
    end

    if params[:art]!=""
      array_order_filters << " AND article_code IN (" + Article.where( :id => params[:art] ).map(&:code).join(',').to_s + ")"
    elsif params[:artspec]!=""
      array_order_filters << " AND LEFT(RIGHT(article_code,8),6) IN (" + Category.where( :id => params[:artspec] ).map(&:code).join(',').to_s + ")"
    elsif params[:artsubgru]!=""
      array_order_filters << " AND LEFT(RIGHT(article_code,8),4) IN (" + Category.where( :id => params[:artsubgru] ).map(&:code).join(',').to_s + ")"
    elsif params[:artgru]!=""
      array_order_filters << " AND LEFT(RIGHT(article_code,8),2) IN (" + Category.where( :id => params[:artgru] ).map(&:code).join(',').to_s + ")"
    end

    if params[:wg]!=""
      array_order_filters << " AND working_group_id IN (" + params[:wg].join(',').to_s + ")"
    end
    array_order = [params[:first], params[:second], params[:third], params[:fourth]].reject(&:empty?)
    if array_order.count < 1
      array_order = ['fase', 'sector', 'working_group_id', 'article']
    end
    array_columns_delivered = ['programado_specific_lvl_1', 'valorizado_specific_lvl_1', 'valor_ganado_specific_lvl_1', 'real_specific_lvl_1', 'meta_specific_lvl_1']
    array_columns_prev_delivered = ['programado_specific_lvl_1', 'valorizado_specific_lvl_1', 'valor_ganado_specific_lvl_1', 'real_specific_lvl_1', 'meta_specific_lvl_1']
    type_amount = 'specific_lvl_1'
    if !params[:type_amount].nil?
      if params[:type_amount][0].include?('specific_lvl_1')
        type_amount = 'specific_lvl_1'
        if !params[:all_actual_values].nil?
          array_columns_delivered = params[:all_actual_values].reject{|x| x=='1'}.map{|s| s + "_"+ params[:type_amount][0] }
        end
        if !params[:all_previous_accumulates].nil?
          # array_columns_delivered = array_columns_delivered + params[:all_actual_accumulate_values].map{|s| s + '_' + params[:type_amount][0] }
          array_columns_prev_delivered = params[:all_previous_accumulates].map{|s| s + '_' + params[:type_amount][0] }
        end
      elsif params[:type_amount][0].include?('measured')
        type_amount = 'measured'
        if !params[:all_actual_values].nil?
          array_columns_delivered = params[:all_actual_values].map{|s| params[:type_amount][0] + '_' + s }
        end
        if !params[:all_previous_accumulates].nil?
          # array_columns_delivered = array_columns_delivered + params[:all_actual_accumulate_values].map{|s| params[:type_amount][0] + '_' + s }
          array_columns_prev_delivered = params[:all_previous_accumulates].map{|s| params[:type_amount][0] + '_' + s }
        end
      end
    end

    @treeOrders = ConsumptionCost.do_order(array_order, table_name, array_columns_delivered, array_columns_prev_delivered, type_amount, array_order_filters, array_values_viewed) rescue nil

    render(partial: 'table_config.html', :layout => false)
  end

end
