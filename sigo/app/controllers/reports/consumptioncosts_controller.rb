class Reports::ConsumptioncostsController < ApplicationController
  before_filter :authenticate_user!
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  

  def index
  	@dates = Array.new
  	cost_center_detail_obj = CostCenter.find(get_company_cost_center('cost_center')).cost_center_detail
  	start_date = cost_center_detail_obj.start_date_of_work
  	end_date = start_date + cost_center_detail_obj.execution_term.days
  	start_date.upto(end_date) do |a|
  		@dates << [a.month, a.year]
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

  	render layout: false
  end

  def consult
    @month = Date.parse(params[:date] + '-01').strftime('%B %Y')
    month = Date.parse(params[:date] + '-01').strftime('%m%Y')
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))
  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	@magic_result_ge = ConsumptionCost.apply_all_general_expenses(cost_center_obj.id, month)
    @magic_result_gen_serv = ConsumptionCost.apply_all_general_services(cost_center_obj.id, month)
    @magic_result_dc = ConsumptionCost.apply_all_direct_cost(cost_center_obj.id, month)

    @accumulated_result_ge = ConsumptionCost.apply_all_accumulated_general_expenses(cost_center_obj.id, month)
    @accumulated_result_gen_serv = ConsumptionCost.apply_all_accumulated_general_services(cost_center_obj.id, month)
    @accumulated_result_dc = ConsumptionCost.apply_all_accumulated_direct_cost(cost_center_obj.id, month)

    @costo_total_programado = @magic_result_dc['sum_programado'].to_f
    @costo_total_valorizado = @magic_result_dc['sum_valorizado'].to_f # => FALTA el valorizado de Gastos Generales
    @costo_total_valor_ganado = @magic_result_dc['sum_valorganado'].to_f
    @costo_total_costo_real = @magic_result_dc['sum_costo_real'].to_f + @magic_result_ge['sum_costo_real'].to_f + @magic_result_gen_serv['sum_costo_real'].to_f
    @costo_total_meta = @magic_result_dc['sum_meta'].to_f + @magic_result_ge['sum_meta'].to_f + @magic_result_gen_serv['sum_meta'].to_f
    @costo_total_accumulado_programado = @accumulated_result_dc['sum_programado'].to_f
    @costo_total_accumulado_valorizado = @accumulated_result_dc['sum_valorizado'].to_f # => FALTA el valorizado de Gastos Generales
    @costo_total_accumulado_valor_ganado = @accumulated_result_dc['sum_valorganado'].to_f
    @costo_total_accumulado_costo_real = @accumulated_result_dc['sum_costo_real'].to_f + @accumulated_result_ge['sum_costo_real'].to_f + @accumulated_result_gen_serv['sum_costo_real'].to_f
    @costo_total_accumulado_meta = @accumulated_result_dc['sum_meta'].to_f + @accumulated_result_ge['sum_meta'].to_f + @accumulated_result_gen_serv['sum_meta'].to_f

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
    type = Phase.find(params[:phase_id])
    subphase = Phase.where("code LIKE '" + type.code + "__'" )
    render json: {:subphase => subphase}  
  end

  def get_subsector
    type = Sector.find(params[:sector_id])
    subsector = Sector.where("code LIKE '" + type.code + "__' AND cost_center_id = " + get_company_cost_center('cost_center') )
    render json: {:subsector => subsector}  
  end

  def get_subgroup
    type = Category.find(params[:group_id])
    subgroup = Category.where("code LIKE '" + type.code + "__'")
    render json: {:subgroup => subgroup}  
  end

  def get_specific
    type = Category.find(params[:subgroup_id])
    specific = Category.where("code LIKE '" + type.code + "__'")
    render json: {:specific => specific}  
  end

  def get_art
    type = Category.find(params[:specific_id])
    article = Article.where("code LIKE '__" + type.code + "__'")
    render json: {:article => article}  
  end 

  def consult_with_config
    @month = Date.parse(params[:date] + '-01').strftime('%m-%Y')
    month = Date.parse(params[:date] + '-01').strftime('%m%Y')
    first = params[:first]
    second = params[:second]
    third = params[:third]
    fourth = params[:fourth]
    phase = params[:phase]
    subphase = params[:subphase]
    sector = params[:sector]
    subsector = params[:subsector]
    wg = params[:wg]
    jf = params[:jf]
    exe = params[:exe]
    cap = params[:cap]
    artgru = params[:artgru]
    artsubgru = params[:artsubgru]
    artspec = params[:artspec]
    art = params[:art]
    cc = get_company_cost_center('cost_center')
    @phases = ConsumptionCost.get_phases(cc, Time.now.to_date.strftime('%m%Y'))
    @total = Array.new
    @total_nombres_fases = Array.new
    @total_nombres_sector = Array.new
    @total_nombres_wg = Array.new
    @phases.to_a.each do |ph|
      phs = Phase.find(ph['id'])
      php = Phase.find_by_code(phs.code[0..1])
      if !@total_nombres_fases.include?(php.name)
        @total << [php.code + " - " + php.name,nil,nil,nil,nil,nil,"fase padre"]
        @total_nombres_fases << php.name
      end
      @total << [phs.code + " - " + phs.name,nil,nil,nil,nil,nil,"fase hija"]
      @sector = ConsumptionCost.get_sector_from_phases(cc, Time.now.to_date.strftime('%m%Y'), phs.id)
      if !@sector.empty?
        @sector.each do |se|
          ses = Sector.find(se['sector_id'])
          sep = Sector.find_by_code(ses.code[0..1])
          if !@total_nombres_sector.include?(sep.name)
            @total << [sep.code + " - " + sep.name,nil,nil,nil,nil,nil,"sector padre"]
            @total_nombres_sector << sep.name
          end          
          @total << [ses.code + " - " + ses.name,nil,nil,nil,nil,nil,"sector hija"]
          @wg = ConsumptionCost.get_wg_from_sector_from_phases(cc, Time.now.to_date.strftime('%m%Y'), phs.id, ses.id)
          if !@wg.empty?
            @wg.each do |wg|
              wgs = WorkingGroup.find(wg['working_group_id'])
              if !@total_nombres_wg.include?(wgs.name)
                @total << [wgs.name,nil,nil,nil,nil,nil,"working_group"]
                @total_nombres_wg << wgs.name
              end
              @articles = ConsumptionCost.get_articles_from_cwgsf(cc, Time.now.to_date.strftime('%m%Y'), phs.id, ses.id, wgs.id)
              @articles.each do |ar|
                @total << [ar['article'], ar['programado_specific_lvl1'],ar['meta_specific_lvl_1'], ar['real_specific_lvl_1'], ar['valorizado_specific_lvl_1'], ar['valor_ganado_specific_lvl_1'], "article"]
              end
            end
          else
            @articles = ConsumptionCost.get_articles_from_swgsf(cc, Time.now.to_date.strftime('%m%Y'), phs.id, ses.id)
            @articles.each do |ar|
              @total << [ar['article'], ar['programado_specific_lvl1'],ar['meta_specific_lvl_1'], ar['real_specific_lvl_1'], ar['valorizado_specific_lvl_1'], ar['valor_ganado_specific_lvl_1'], "article"]
            end
          end
        end
      else
        @articles =ConsumptionCost.get_articles_from_phases(cc, Time.now.to_date.strftime('%m%Y'), phs.id)
        @articles.each do |ar|
          @total << [ar['article'], ar['programado_specific_lvl1'],ar['meta_specific_lvl_1'], ar['real_specific_lvl_1'], ar['valorizado_specific_lvl_1'], ar['valor_ganado_specific_lvl_1'], "article"]
        end        
      end
    end
    render(partial: 'table_with_config.html', :layout => false)
  end   
end
