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
    @month = Date.parse(params[:date] + '-01').strftime('%B %Y')
    month = Date.parse(params[:date] + '-01').strftime('%m%Y')
  	cost_center_obj = CostCenter.find(get_company_cost_center('cost_center'))

  	@cost_center_str = cost_center_obj.company.name.to_s + ': ' + ' CC ' + cost_center_obj.code.to_s + ' - ' + cost_center_obj.name.to_s
  	@magic_result_ge = ConsumptionCost.apply_all_general_expenses(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH
    @magic_result_gen_serv = ConsumptionCost.apply_all_general_services(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH
    @magic_result_dc = ConsumptionCost.apply_all_direct_cost(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH

    @accumulated_result_ge = ConsumptionCost.apply_all_accumulated_general_expenses(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH
    @accumulated_result_gen_serv = ConsumptionCost.apply_all_accumulated_general_services(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH
    @accumulated_result_dc = ConsumptionCost.apply_all_accumulated_direct_cost(cost_center_obj.id, Time.now.to_date.strftime('%m%Y')) # => MODIFICAR A MONTH

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
    # cc_id, date, insertion_date, select, table, condition_id, condition, order
    @total = Array.new
    @total_nombres_fases = Array.new
    @total_nombres_sector = Array.new
    @total_nombres_wg = Array.new
    @total_nombres_category = Array.new
    ["CD","GG","SG"].each do |cat|
      if first == "defecto"  && second == "defecto"  && third == "defecto"  && fourth == "defecto"

        @phases = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`", ", `phases` ph", "fase_cod_hijo =  ph.code", " ", "ph.code", cat)
        @phases.to_a.each do |ph|
          phs = Phase.find_by_code(ph['fase_cod_hijo'])
          php = Phase.find_by_code(phs.code[0..1])
          if !@total_nombres_fases.include?(php.name)
            @total << [php.code + " - " + php.name,nil,nil,nil,nil,nil,"fase padre"]
            @total_nombres_fases << php.name
          end
          @total << [phs.code + " - " + phs.name,nil,nil,nil,nil,nil,"fase hija"]
          @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`", ", `sectors` sc", "sector_cod_hijo =  sc.code", " AND acc.fase_cod_hijo = #{phs.code}", "sc.code", cat)
          if !@sector.empty?
            @sector.each do |se|
              ses = Sector.find_by_code(se['sector_cod_hijo'])
              sep = Sector.find_by_code(ses.code[0..1])
              if !@total_nombres_sector.include?(sep.name)
                @total << [sep.code + " - " + sep.name,nil,nil,nil,nil,nil,"sector padre"]
                @total_nombres_sector << sep.name
              end          
              @total << [ses.code + " - " + ses.name,nil,nil,nil,nil,nil,"sector hija"]
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{phs.code} AND acc.sector_cod_hijo = #{ses.code}", "wg.name", cat)
              if !@wg.empty?
                @wg.each do |wg|
                  wgs = WorkingGroup.find(wg['working_group_id'])
                  if !@total_nombres_wg.include?(wgs.name)
                    @total << [wgs.name,nil,nil,nil,nil,nil,"working_group"]
                    @total_nombres_wg << wgs.name
                  end
                  @articles = ConsumptionCost.get_articles_from_cwgsf(cc, Time.now.to_date.strftime('%m%Y'), phs.code, ses.code, wgs.id)
                  @articles.each do |ar|
                    @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                  end
                end
              else
                @articles = ConsumptionCost.get_articles_from_swgsf(cc, Time.now.to_date.strftime('%m%Y'), phs.code, ses.code)
                @articles.each do |ar|
                  @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                end
              end
            end
          else
            @articles =ConsumptionCost.get_articles_from_phases(cc, Time.now.to_date.strftime('%m%Y'), phs.code)
            @articles.each do |ar|
              @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
            end        
          end
        end
      end

      # ----------------------------------- EMPIEZAN COMBINACIONES -----------------------------------
      # --------------------------- FASE PRIMERO ------------------------------------
      if first == "phase"
        if phase != ""
          extra = Phase.where("id IN (#{phase.join(',')})")
          code = Array.new
          extra.each do |ex|
            code << ex.code
          end
          @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')})", "ph.code", cat)
        elsif subphase != ""
          @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')})", "ph.code", cat)
        else
          @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " ", "ph.code", cat)
        end
        @phase.each do |fa|
          if !@total_nombres_fases.include?(fa['phase_father'])
            @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
            @total_nombres_fases << fa['phase_father']
          end
          name = Phase.find_by_code(fa['fase_cod_hijo'])
          @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
          if second == "sector"
            if sector != ""
              extra = Sector.where("id IN (#{sector.join(',')})")
              code = Array.new
              extra.each do |ex|
                code << ex.code
              end
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "se.code", cat)
            elsif subsector != ""
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "se.code", cat)
            else
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "se.code", cat)
            end
            @sector.each do |se|
              if !@total_nombres_sector.include?(se['sector_padre'])
                @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                @total_nombres_sector << se['sector_padre']
              end
              name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
              @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
              if third == "article" && fourth == "working_group"
                cad_in = Array.new
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                end
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) ", "wg.name", cat)
                      end
                      @wg.each do |wg|
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end 

              elsif third == "working_group" && fourth == "article"
                if wg != ""
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && cap!= ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && cap!= "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                else
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                end
                @wg.each do |wg|
                  if !@total_nombres_wg.include?(wg['name'])
                    @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                    @total_nombres_fases << wg['name']
                  end                  
                  cad_in = Array.new
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end
              end
            end

          elsif second == "working_group"
            if wg != ""
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "wg.name", cat)
            elsif jf != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && exe != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && cap!= ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && cap!= "" && exe != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "wg.name", cat)
            else
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} ", "wg.name", cat)
            end
            @wg.each do |wg|
              if !@total_nombres_wg.include?(wg['name'])
                @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                @total_nombres_fases << wg['name']
              end               
              if third == "sector" && fourth == "article"
                if sector != ""
                  extra = Sector.where("id IN (#{sector.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                elsif subsector != ""
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                else
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                end
                @sector.each do |se|
                  if !@total_nombres_sector.include?(se['sector_padre'])
                    @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                    @total_nombres_sector << se['sector_padre']
                  end
                  name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                  @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end                  
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end

              elsif third == "article" && fourth == "sector"
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                end
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end

                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      i = 1
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]                        
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end
              end
            end

          elsif second == "article"
            if artgru != ""
              Category.where("id IN (#{artgru.join(',')})").each do |cat|
                cad_in << cat.code
              end
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
            else
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
            end
            @group.each do |gr|
              code_group_name = Category.find_by_code(gr['group_code']).name
              if !@total_nombres_wg.include?(code_group_name)
                @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                @total_nombres_fases << code_group_name
              end                      
              if artsubgru != ""
                Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                  cad_in << cat.code
                end
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
              else
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
              end
              @sub_group.each do |sgr|
                code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                if !@total_nombres_wg.include?(code_group_name)
                  @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                  @total_nombres_fases << code_group_name
                end                        
                if artspec != ""
                  Category.where("id IN (#{artspec.join(',')}").each do |cat|
                    cad_in << cat.code
                  end
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
                else
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']}", "art.code", cat)
                end
                @specific.each do |spe|
                  code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                    @total_nombres_fases << code_group_name
                  end
                  if third == "working_group" && fourth == "sector"
                    if wg != ""
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    else
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "wg.name", cat)
                    end
                    @wg.each do |wg| 
                      if !@total_nombres_wg.include?(wg['name'])
                        @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                        @total_nombres_fases << wg['name']
                      end
                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  elsif third == "sector" && fourth == "working_group"
                    if sector != ""
                      extra = Sector.where("id IN (#{sector.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    elsif subsector != ""
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    else
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    end
                    @sector.each do |se|
                      if !@total_nombres_sector.include?(se['sector_padre'])
                        @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                        @total_nombres_sector << se['sector_padre']
                      end
                      name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                      @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                      end
                      @wg.each do |wg| 
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
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

      # --------------------------- SECTOR PRIMERO ------------------------------------
      if first == "sector"
        if sector != ""
          extra = Sector.where("id IN (#{sector.join(',')})")
          code = Array.new
          extra.each do |ex|
            code << ex.code
          end
          @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')})", "se.code", cat)
        elsif subsector != ""
          @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')})", "se.code", cat)
        else
          @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " ", "se.code", cat)
        end
        @sector.each do |se|
          if !@total_nombres_sector.include?(se['sector_padre'])
            @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
            @total_nombres_sector << se['sector_padre']
          end
          name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
          @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
          if second == "phase"
            if phase != ""
              extra = Phase.where("id IN (#{phase.join(',')})")
              code = Array.new
              extra.each do |ex|
                code << ex.code
              end
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "ph.code", cat)
            elsif subphase != ""
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "ph.code", cat)
            else
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} ", "ph.code", cat)
            end
            @phase.each do |fa|
              if !@total_nombres_fases.include?(fa['phase_father'])
                @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                @total_nombres_fases << fa['phase_father']
              end
              name = Phase.find_by_code(fa['fase_cod_hijo'])
              @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]              
              if third == "article" && fourth == "working_group"
                cad_in = Array.new
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                end
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) ", "wg.name", cat)
                      end
                      @wg.each do |wg|
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end                 
              elsif third == "working_group" && fourth == "article"
                if wg != ""
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && cap!= ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                elsif jf != "" && cap!= "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                else
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                end
                @wg.each do |wg|
                  if !@total_nombres_wg.include?(wg['name'])
                    @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                    @total_nombres_fases << wg['name']
                  end                  
                  cad_in = Array.new
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end
              end
              
            end

          elsif second == "article"
            if artgru != ""
              Category.where("id IN (#{artgru.join(',')})").each do |cat|
                cad_in << cat.code
              end
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
            else
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
            end
            @group.each do |gr|
              code_group_name = Category.find_by_code(gr['group_code']).name
              if !@total_nombres_wg.include?(code_group_name)
                @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                @total_nombres_fases << code_group_name
              end                      
              if artsubgru != ""
                Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                  cad_in << cat.code
                end
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
              else
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
              end
              @sub_group.each do |sgr|
                code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                if !@total_nombres_wg.include?(code_group_name)
                  @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                  @total_nombres_fases << code_group_name
                end                        
                if artspec != ""
                  Category.where("id IN (#{artspec.join(',')}").each do |cat|
                    cad_in << cat.code
                  end
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                else
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "art.code", cat)
                end
                @specific.each do |spe|
                  code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                    @total_nombres_fases << code_group_name
                  end

                  if third == "working_group" && fourth == "phase"
                    if wg != ""
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    else
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    end
                    @wg.each do |wg|
                      if !@total_nombres_wg.include?(wg['name'])
                        @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                        @total_nombres_fases << wg['name']
                      end                  
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end                        
                      end    
                    end

                  elsif third == "phase" && fourth == "working_group"
                    if phase != ""
                      extra = Phase.where("id IN (#{phase.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    elsif subphase != ""
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    else
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                    end
                    @phase.each do |fa|
                      if !@total_nombres_fases.include?(fa['phase_father'])
                        @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                        @total_nombres_fases << fa['phase_father']
                      end
                      name = Phase.find_by_code(fa['fase_cod_hijo'])
                      @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                      end
                      @wg.each do |wg| 
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end                        
                      end
                    end                
                  end
                end
              end
            end 

          elsif second == "working_group"
            if wg != ""
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            elsif jf != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && exe != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && cap!= ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            elsif jf != "" && cap!= "" && exe != ""
              wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
              ids = Array.new()
              wg.each do |w|
                ids << w.id
              end
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            else
              @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
            end
            @wg.each do |wg|
              if !@total_nombres_wg.include?(wg['name'])
                @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                @total_nombres_fases << wg['name']
              end
              if third == "phase" && fourth == "article"
                if phase != ""
                  extra = Phase.where("id IN (#{phase.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                elsif subphase != ""
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                else
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
                end
                @phase.each do |fa|
                  if !@total_nombres_fases.include?(fa['phase_father'])
                    @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                    @total_nombres_fases << fa['phase_father']
                  end
                  name = Phase.find_by_code(fa['fase_cod_hijo'])
                  @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end                  
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end                  
                end
              elsif third == "article" && fourth == "phase"
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                end                  
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]                      
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
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

      # --------------------------- WORKING GROUP PRIMERO ------------------------------------
      if first == "working_group"
        if wg != ""
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')})", "wg.name", cat)
        elsif jf != ""
          wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
          ids = Array.new()
          wg.each do |w|
            ids << w.id
          end
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')})", "wg.name", cat)
        elsif jf != "" && exe != ""
          wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
          ids = Array.new()
          wg.each do |w|
            ids << w.id
          end
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')})", "wg.name", cat)
        elsif jf != "" && cap!= ""
          wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
          ids = Array.new()
          wg.each do |w|
            ids << w.id
          end
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')})", "wg.name", cat)
        elsif jf != "" && cap!= "" && exe != ""
          wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
          ids = Array.new()
          wg.each do |w|
            ids << w.id
          end
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')})", "wg.name", cat)
        else
          @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", "", "wg.name", cat)
        end
        @wg.each do |wg|
          if !@total_nombres_wg.include?(wg['name'])
            @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
            @total_nombres_fases << wg['name']
          end        
          if second == "sector"
            if sector != ""
              extra = Sector.where("id IN (#{sector.join(',')})")
              code = Array.new
              extra.each do |ex|
                code << ex.code
              end
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')})", "se.code", cat)
            elsif subsector != ""
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')})", "se.code", cat)
            else
              @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " ", "se.code", cat)
            end
            @sector.each do |se|
              if !@total_nombres_sector.include?(se['sector_padre'])
                @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                @total_nombres_sector << se['sector_padre']
              end
              name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
              @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]            
              if third == "article" && fourth == "phase"
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                end
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end                        
                      end
                    end
                  end
                end            

              elsif third == "phase" && fourth == "article"
                if phase != ""
                  extra = Phase.where("id IN (#{phase.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                elsif subphase != ""
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                else
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
                end
                @phase.each do |fa|
                  if !@total_nombres_fases.include?(fa['phase_father'])
                    @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                    @total_nombres_fases << fa['phase_father']
                  end
                  name = Phase.find_by_code(fa['fase_cod_hijo'])
                  @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end                  
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end                  
                end
              end
            end
          elsif second == "phase"
            if phase != ""
              extra = Phase.where("id IN (#{phase.join(',')})")
              code = Array.new
              extra.each do |ex|
                code << ex.code
              end
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
            elsif subphase != ""
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
            else
              @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
            end
            @phase.each do |fa|
              if !@total_nombres_fases.include?(fa['phase_father'])
                @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                @total_nombres_fases << fa['phase_father']
              end
              name = Phase.find_by_code(fa['fase_cod_hijo'])
              @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]            
              if third == "sector" && fourth == "article"
                if sector != ""
                  extra = Sector.where("id IN (#{sector.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                elsif subsector != ""
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                else
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "se.code", cat)
                end
                @sector.each do |se|
                  if !@total_nombres_sector.include?(se['sector_padre'])
                    @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                    @total_nombres_sector << se['sector_padre']
                  end
                  name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                  @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                  if artgru != ""
                    Category.where("id IN (#{artgru.join(',')})").each do |cat|
                      cad_in << cat.code
                    end
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end                  
                  @group.each do |gr|
                    code_group_name = Category.find_by_code(gr['group_code']).name
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                      @total_nombres_fases << code_group_name
                    end                      
                    if artsubgru != ""
                      Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @sub_group.each do |sgr|
                      code_group_name = Category.find_by_code(sgr['sub_group_code']).name
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                        @total_nombres_fases << code_group_name
                      end                        
                      if artspec != ""
                        Category.where("id IN (#{artspec.join(',')}").each do |cat|
                          cad_in << cat.code
                        end
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      else
                        @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                      end
                      @specific.each do |spe|
                        code_group_name = Category.find_by_code(spe['specifics']).name
                        if !@total_nombres_wg.include?(code_group_name)
                          @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                          @total_nombres_fases << code_group_name
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end

              elsif third == "article" && fourth == "sector"
                if artgru != ""
                  Category.where("id IN (#{artgru.join(',')})").each do |cat|
                    cad_in << cat.code
                  end
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                else
                  @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                end
                @group.each do |gr|
                  code_group_name = Category.find_by_code(gr['group_code']).name
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                    @total_nombres_fases << code_group_name
                  end                      
                  if artsubgru != ""
                    Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                      cad_in << cat.code
                    end
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  else
                    @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                  end
                  @sub_group.each do |sgr|
                    code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                    if !@total_nombres_wg.include?(code_group_name)
                      @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                      @total_nombres_fases << code_group_name
                    end                        
                    if artspec != ""
                      Category.where("id IN (#{artspec.join(',')}").each do |cat|
                        cad_in << cat.code
                      end
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    else
                      @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                    end
                    @specific.each do |spe|
                      code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                      if !@total_nombres_wg.include?(code_group_name)
                        @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                        @total_nombres_fases << code_group_name
                      end

                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND LEFT(RIGHT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      i = 1
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]                        
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end
              end
            end
          elsif second == "article"
            if artgru != ""
              Category.where("id IN (#{artgru.join(',')})").each do |cat|
                cad_in << cat.code
              end
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')}) AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
            else
              @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
            end
            @group.each do |gr|
              code_group_name = Category.find_by_code(gr['group_code']).name
              if !@total_nombres_wg.include?(code_group_name)
                @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
                @total_nombres_fases << code_group_name
              end                      
              if artsubgru != ""
                Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
                  cad_in << cat.code
                end
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')}) AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
              else
                @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
              end
              @sub_group.each do |sgr|
                code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
                if !@total_nombres_wg.include?(code_group_name)
                  @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
                  @total_nombres_fases << code_group_name
                end                        
                if artspec != ""
                  Category.where("id IN (#{artspec.join(',')}").each do |cat|
                    cad_in << cat.code
                  end
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')}) AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                else
                  @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND acc.working_group_id = #{wg['working_group_id']}", "art.code", cat)
                end
                @specific.each do |spe|
                  code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
                  if !@total_nombres_wg.include?(code_group_name)
                    @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                    @total_nombres_fases << code_group_name
                  end
                  if third == "phase" && fourth == "sector"
                    if phase != ""
                      extra = Phase.where("id IN (#{phase.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    elsif subphase != ""
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    else
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                    end
                    @phase.each do |fa|
                      if !@total_nombres_fases.include?(fa['phase_father'])
                        @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                        @total_nombres_fases << fa['phase_father']
                      end
                      name = Phase.find_by_code(fa['fase_cod_hijo'])
                      @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  elsif third == "sector" && fourth == "phase"
                    if sector != ""
                      extra = Sector.where("id IN (#{sector.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    elsif subsector != ""
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    else
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    end
                    @sector.each do |se|
                      if !@total_nombres_sector.include?(se['sector_padre'])
                        @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                        @total_nombres_sector << se['sector_padre']
                      end
                      name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                      @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]                        
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
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

      # --------------------------- ARTICLE CODE PRIMERO ------------------------------------
      if first == "article"
        if artgru != ""
          Category.where("id IN (#{artgru.join(',')})").each do |cat|
            cad_in << cat.code
          end
          @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 4),2) IN (#{cad_in.join(',')})", "art.code", cat)
        else
          @group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,4),2) AS group_code", ", `articles` art", "article_code =  art.code", "", "art.code", cat)
        end
        @group.each do |gr|
          code_group_name = Category.find_by_code(gr['group_code']).name
          if !@total_nombres_wg.include?(code_group_name)
            @total << [code_group_name,nil,nil,nil,nil,nil,"article group"]
            @total_nombres_fases << code_group_name
          end                      
          if artsubgru != ""
            Category.where("id IN (#{artsubgru.join(',')}").each do |cat|
              cad_in << cat.code
            end
            @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 6),4) IN (#{cad_in.join(',')})", "art.code", cat)
          else
            @sub_group = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,6),4) AS sub_group_code", ", `articles` art", "article_code =  art.code", "", "art.code", cat)
          end
          @sub_group.each do |sgr|
            code_group_name = Category.find_by_code(sgr['sub_group_code']).name rescue nil
            if !@total_nombres_wg.include?(code_group_name)
              @total << [code_group_name,nil,nil,nil,nil,nil,"article sub_group"]
              @total_nombres_fases << code_group_name
            end                        
            if artspec != ""
              Category.where("id IN (#{artspec.join(',')}").each do |cat|
                cad_in << cat.code
              end
              @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", " AND RIGHT(LEFT(art.code, 8),6) IN (#{cad_in.join(',')})", "art.code", cat)
            else
              @specific = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "RIGHT(LEFT(`acc`.`article_code`,8),6) AS specifics", ", `articles` art", "article_code =  art.code", "", "art.code", cat)
            end
            @specific.each do |spe|
              code_group_name = Category.find_by_code(spe['specifics']).name rescue nil
              if !@total_nombres_wg.include?(code_group_name)
                @total << [code_group_name,nil,nil,nil,nil,nil,"article specific"]
                @total_nombres_fases << code_group_name
              end
              if second == "working_group"
                if wg != ""
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND RIGHT(LEFT(art.code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                elsif jf != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND RIGHT(LEFT(art.code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                elsif jf != "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND RIGHT(LEFT(art.code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                elsif jf != "" && cap!= ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND RIGHT(LEFT(art.code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                elsif jf != "" && cap!= "" && exe != ""
                  wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                  ids = Array.new()
                  wg.each do |w|
                    ids << w.id
                  end
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                else
                  @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                end
                @wg.each do |wg|
                  if !@total_nombres_wg.include?(wg['name'])
                    @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                    @total_nombres_fases << wg['name']
                  end
                  if third == "phase" && fourth == "sector"
                    if phase != ""
                      extra = Phase.where("id IN (#{phase.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    elsif subphase != ""
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    else
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                    end
                    @phase.each do |fa|
                      if !@total_nombres_fases.include?(fa['phase_father'])
                        @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                        @total_nombres_fases << fa['phase_father']
                      end
                      name = Phase.find_by_code(fa['fase_cod_hijo'])
                      @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  elsif third == "sector" && fourth == "phase"
                    if sector != ""
                      extra = Sector.where("id IN (#{sector.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    elsif subsector != ""
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    else
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    end
                    @sector.each do |se|
                      if !@total_nombres_sector.include?(se['sector_padre'])
                        @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                        @total_nombres_sector << se['sector_padre']
                      end
                      name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                      @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]                        
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  end
                end
                  
              elsif second == "phase"
                if phase != ""
                  extra = Phase.where("id IN (#{phase.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                elsif subphase != ""
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                else
                  @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                end
                @phase.each do |fa|
                  if !@total_nombres_fases.include?(fa['phase_father'])
                    @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                    @total_nombres_fases << fa['phase_father']
                  end
                  name = Phase.find_by_code(fa['fase_cod_hijo'])
                  @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]                
                  if third == "working_group" && fourth == "sector"
                    if wg != ""
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "wg.name", cat)
                    else
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "wg.name", cat)
                    end
                    @wg.each do |wg| 
                      if !@total_nombres_wg.include?(wg['name'])
                        @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                        @total_nombres_fases << wg['name']
                      end
                      if sector != ""
                        extra = Sector.where("id IN (#{sector.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      elsif subsector != ""
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      else
                        @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                      end
                      @sector.each do |se|
                        if !@total_nombres_sector.include?(se['sector_padre'])
                          @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                          @total_nombres_sector << se['sector_padre']
                        end
                        name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                        @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end
                      end
                    end
                  elsif third == "sector" && fourth == "working_group"
                    if sector != ""
                      extra = Sector.where("id IN (#{sector.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    elsif subsector != ""
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    else
                      @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                    end
                    @sector.each do |se|
                      if !@total_nombres_sector.include?(se['sector_padre'])
                        @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                        @total_nombres_sector << se['sector_padre']
                      end
                      name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                      @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                      end
                      @wg.each do |wg| 
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end                        
                      end
                    end
                  end
                end
              elsif second == "sector"
                if sector != ""
                  extra = Sector.where("id IN (#{sector.join(',')})")
                  code = Array.new
                  extra.each do |ex|
                    code << ex.code
                  end
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND se.code IN (#{code.join(',')} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                elsif subsector != ""
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo =  se.code", " AND se.id IN (#{subsector.join(',')}) AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                else
                  @sector = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`sector_cod_hijo`, CONCAT(`acc`.`sector_cod_padre`, ' - ', `acc`.`sector_cod_padre_nombre`) AS sector_padre", ", `sectors` se", "sector_cod_hijo = se.code", " AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "se.code", cat)
                end
                @sector.each do |se|
                  if !@total_nombres_sector.include?(se['sector_padre'])
                    @total << [se['sector_padre'],nil,nil,nil,nil,nil,"sector padre"]
                    @total_nombres_sector << se['sector_padre']
                  end
                  name_se = Sector.where("cost_center_id = " + get_company_cost_center('cost_center').to_s + " AND code = " + se['sector_cod_hijo'].to_s).first
                  @total << [name_se.code + " - " + name_se.name,nil,nil,nil,nil,nil,"sector hija"]
                  if third == "working_group" && fourth == "phase"
                    if wg != ""
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    elsif jf != "" && cap!= "" && exe != ""
                      wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                      ids = Array.new()
                      wg.each do |w|
                        ids << w.id
                      end
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    else
                      @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "wg.name", cat)
                    end
                    @wg.each do |wg|
                      if !@total_nombres_wg.include?(wg['name'])
                        @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                        @total_nombres_fases << wg['name']
                      end                  
                      if phase != ""
                        extra = Phase.where("id IN (#{phase.join(',')})")
                        code = Array.new
                        extra.each do |ex|
                          code << ex.code
                        end
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      elsif subphase != ""
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']}", "ph.code", cat)
                      else
                        @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} AND acc.working_group_id = #{wg['working_group_id']} ", "ph.code", cat)
                      end
                      @phase.each do |fa|
                        if !@total_nombres_fases.include?(fa['phase_father'])
                          @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                          @total_nombres_fases << fa['phase_father']
                        end
                        name = Phase.find_by_code(fa['fase_cod_hijo'])
                        @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(art.code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
                        end                        
                      end    
                    end

                  elsif third == "phase" && fourth == "working_group"
                    if phase != ""
                      extra = Phase.where("id IN (#{phase.join(',')})")
                      code = Array.new
                      extra.each do |ex|
                        code << ex.code
                      end
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.code IN (#{code.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    elsif subphase != ""
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND ph.id IN (#{subphase.join(',')}) AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']}", "ph.code", cat)
                    else
                      @phase = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`fase_cod_hijo`, CONCAT(`acc`.`fase_cod_padre`, ' - ', `acc`.`fase_cod_padre_nombre`) AS phase_father", ", `phases` ph", "fase_cod_hijo =  ph.code", " AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND RIGHT(LEFT(acc.article_code, 8),6) = #{spe['specifics']} ", "ph.code", cat)
                    end
                    @phase.each do |fa|
                      if !@total_nombres_fases.include?(fa['phase_father'])
                        @total << [fa['phase_father'],nil,nil,nil,nil,nil,"fase padre"]
                        @total_nombres_fases << fa['phase_father']
                      end
                      name = Phase.find_by_code(fa['fase_cod_hijo'])
                      @total << [name.code + " - " + name.name,nil,nil,nil,nil,nil,"fase hija"]
                      if wg != ""
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{wg.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      elsif jf != "" && cap!= "" && exe != ""
                        wg = WorkingGroup.where("front_chief_id IN (#{jf.join(',')}) AND executor_id IN (#{exe.join(',')}) AND master_builder_id IN (#{cap.join(',')}) AND active = 1 AND cost_center_id = " + get_company_cost_center('cost_center').to_s )
                        ids = Array.new()
                        wg.each do |w|
                          ids << w.id
                        end
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND wg.id IN (#{ids.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']}", "wg.name", cat)
                      else
                        @wg = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "`acc`.`working_group_id`, `wg`.`name`", ", `working_groups` wg", "working_group_id =  wg.id", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} AND sector_cod_hijo = #{se['sector_cod_hijo']} ", "wg.name", cat)
                      end
                      @wg.each do |wg| 
                        if !@total_nombres_wg.include?(wg['name'])
                          @total << [wg['name'],nil,nil,nil,nil,nil,"working_group"]
                          @total_nombres_fases << wg['name']
                        end
                        if art != ""
                          Article.where("id IN (#{art.join(',')}").each do |cat|
                            cad_in << cat.code
                          end
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND art.code IN (#{cad_in.join(',')}) AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']}", "art.code", cat)
                        else
                          @article = ConsumptionCost.get_phases_sector_wg(cc, Time.now.to_date.strftime('%m%Y'), Time.now.to_date.strftime('%Y-%m-%d'), "CONCAT(`acc`.`article_code` , ' - ', `acc`.`article_name`, ' - ', `acc`.`article_unit`) AS article, acc.`programado_specific_lvl1`, acc.`meta_specific_lvl_1`, acc.`real_specific_lvl_1`, acc.`valorizado_specific_lvl_1`, acc.`valor_ganado_specific_lvl_1`", ", `articles` art", "article_code =  art.code", " AND acc.fase_cod_hijo = #{fa['fase_cod_hijo']} AND acc.sector_cod_hijo = #{se['sector_cod_hijo']} AND acc.working_group_id = #{wg['working_group_id']} AND RIGHT(LEFT(acc.article_code,8),6) = #{spe['specifics']} ", "art.code", cat)
                        end
                        @article.each do |art|
                          @total << [art['article'], art['programado_specific_lvl1'],art['meta_specific_lvl_1'], art['real_specific_lvl_1'], art['valorizado_specific_lvl_1'], art['valor_ganado_specific_lvl_1'], "article"]
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

      @total_nombres_fases = Array.new
      @total_nombres_sector = Array.new
      @total_nombres_wg = Array.new
      @total_nombres_category = Array.new
    end

    render(partial: 'table_with_config.html', :layout => false)
  end   
end
