class Production::DailyWorks::WeeklyWorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update, :graph ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    @workingGroups = WorkingGroup.all
    @weeklyworker = WeeklyWorker.all
    @cost_center = get_company_cost_center('cost_center')
    render layout: false
  end

  def create
    weekly_worker = WeeklyWorker.new(weekly_table_parameters)
    weekly_worker.state
    if weekly_worker.save
      redirect_to :action => :index, company_id: params[:company_id]
    else
      weekly_worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def new
    @workingGroups = WorkingGroup.all
    @week = CostCenter.getWeek(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def show
    @weekly_work=WeeklyWorker.find_by_id(params[:id])
    @blockweekly = params[:blockweekly]
    @inicio = @weekly_work.start_date
    @fin = @weekly_work.end_date
    @cad = @weekly_work.working_group.split(" ")
    @cad = @cad.join(',')
    @dias_habiles =  range_business_days(@inicio,@fin)
    @gruposdetrabajos = WorkingGroup.all
    @tareos_total_arrays = []
    @subcontratista_arrays = []
    @gruposdetrabajos.each do |gruposdetrabajo|
      temp_tareo = []
      temp_tareo = business_days_array(@inicio,@fin,@cad,@dias_habiles,@blockweekly)          
      if temp_tareo.length != 0 
        @tareos_total_arrays << temp_tareo
        subcontratista_nombre = "#{gruposdetrabajo.name} - #{Entity.find(Worker.find(gruposdetrabajo.front_chief_id).entity_id).name} - #{Entity.find_name_executor(gruposdetrabajo.executor_id)} - #{Entity.find(Worker.find(gruposdetrabajo.master_builder_id).entity_id).name}"
        @subcontratista_arrays << subcontratista_nombre
      end
      break
    end

    if @dias_habiles.length == 0
      @pase = 3
      render layout: false
    else
      if @tareos_total_arrays.length != 0
        @pase = 4
        render layout: false
      else
        @pase = 2
        render layout: false
      end
    end
  end

  def approve
    start_date = params[:start_date].inspect
    end_date = params[:end_date].inspect
    updateParts(start_date,end_date)
    weekly_worker = WeeklyWorker.find(params[:id])
    weekly_worker.approve
    redirect_to :action => :index
  end

  def destroy
    weekly_worker = WeeklyWorker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el tareo semanal de obreros."
    render :json => weekly_worker
  end

  def weekly_table
    @weekly_work=WeeklyWorker.find_by_id(params[:id])
    @blockweekly = params[:blockweekly]
    @inicio = @weekly_work.start_date
    @fin = @weekly_work.end_date
    @cad = @weekly_work.working_group.split(" ")
    @cad = @cad.join(',')
    @dias_habiles =  range_business_days(@inicio,@fin)
    @gruposdetrabajos = WorkingGroup.all
    @tareos_total_arrays = []
    @subcontratista_arrays = []
    @gruposdetrabajos.each do |gruposdetrabajo|
      temp_tareo = []
      temp_tareo = business_days_array(@inicio,@fin,@cad,@dias_habiles,@blockweekly)          
      if temp_tareo.length != 0 
        @tareos_total_arrays << temp_tareo
        subcontratista_nombre = "#{gruposdetrabajo.name} - #{Entity.find(Worker.find(gruposdetrabajo.front_chief_id).entity_id).name} - #{Entity.find_name_executor(gruposdetrabajo.executor_id)} - #{Entity.find(Worker.find(gruposdetrabajo.master_builder_id).entity_id).name}"
        @subcontratista_arrays << subcontratista_nombre
      end
      break
    end

    if @dias_habiles.length == 0
      @pase = 3
      render layout: false
    else
      if @tareos_total_arrays.length != 0
        @pase = 4
        render layout: false
      else
        @pase = 2
        render layout: false
      end
    end
  end

  def range_business_days(start_date, end_date)
    start_date_var = start_date.to_date
    end_date_var = end_date.to_date
    business_days = []
    while end_date_var >= start_date_var
      business_days << start_date_var
      start_date_var = start_date_var + 1.day
    end
    return business_days
  end

  def business_days_array(start_date, end_date, working_group_id, business_days,blockweekly)
    personals_array = []
    trabajadores_array = []
    partediariodepersonals = PartPerson.where("working_group_id IN ("+working_group_id+") and blockweekly = ? and date_of_creation BETWEEN ? AND ?", blockweekly,start_date,end_date)
    partediariodepersonals.each do |partediariodepersonal|
      partediariodepersonal.part_person_details.each do |trabajador_detalle|
        trabajadore = trabajador_detalle.worker
        id = trabajadore.id
        nombre = "#{trabajadore.entity.paternal_surname + ' ' + trabajadore.entity.maternal_surname}, #{trabajadore.entity.name}  #{trabajadore.entity.second_name}"
        contrato = WorkerContract.find_by_worker_id(trabajadore.id)
        categoria = "#{contrato.article.name}"              
        total_horas     = trabajador_detalle.total_hours.to_f
        total_normales  = trabajador_detalle.normal_hours.to_f
        total_60        = trabajador_detalle.he_60.to_f
        total_100       = trabajador_detalle.he_100.to_f
        rango_dias = []
        business_days.each do |dia|
          if partediariodepersonal.date_of_creation  == dia.to_date
            rango_dias << trabajador_detalle.total_hours.to_f
          else
            rango_dias << 0
          end               
        end              
        # [0]     =>     id                           trabajadores
        # [1]     =>     nombre                       nombreTrabajador
        # [2]     =>     categoria                    catalogotrabajadores
        # [3]     =>     Dias                         exterior calculo de dias
        # [4]     =>     total_horas                  trabajadores 
        # [5]     =>     total_normales               trabajadores
        # [6]     =>     total_60                     trabajadores
        # [7]     =>     total_100                    trabajadores
        trabajadores_array << [id,nombre,categoria,rango_dias,total_horas,total_normales,total_60,total_100]
      end
    end
    return filter_array_business_days(trabajadores_array)
  end

  def updateParts(start_date, end_date)
    ActiveRecord::Base.connection.execute("
      Update part_people set blockweekly = 1 where date_of_creation BETWEEN " + start_date + " AND " + end_date + "
    ")
  end

  def graph
    @week = CostCenter.getWeek5(get_company_cost_center('cost_center'),Time.now.to_date.to_s)
    render layout: false
  end

  def graph_week
    @names= Array.new
    @result = params[:start_date].split(/,/)
    start_date = @result[1]
    end_date = @result[2]
    @costcenter = get_company_cost_center('cost_center')
    weeks = ActiveRecord::Base.connection.execute("
      SELECT wcc.id
      FROM  weeks_for_cost_center_"+@costcenter.to_s+" wcc
      WHERE  wcc.start_date <  '"+end_date.to_s+"' AND wcc.end_date >  '"+start_date.to_s+"'"
    )
    weeks.each do |id|
      if id[0].to_i<13
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_"+@costcenter+" wcc
          WHERE  wcc.end_date <  '"+id[2].to_date.to_s+"'
        ")
      else
        first_id = id[0].to_i-9
        last_id = id[0].to_i + 1
        @weeks = ActiveRecord::Base.connection.execute("
          SELECT wcc.name, wcc.start_date, wcc.end_date
          FROM  weeks_for_cost_center_"+@costcenter.to_s+" wcc
          WHERE  wcc.id >="+first_id.to_i.to_s+" AND wcc.id < "+last_id.to_s+"
        ")
      end
    end
    @weekhh =Array.new
    @weekcp =Array.new
    @weeks.each do|inter|
      @weekhh << ActiveRecord::Base.connection.execute("
        SELECT ar.name
        FROM part_people pp, part_person_details ppd, articles ar, workers w, worker_contracts wc, categories c
        WHERE pp.cost_center_id = "+@costcenter.to_s+"
        AND pp.date_of_creation BETWEEN '" + inter[1].to_date.to_s + "' AND '" + inter[2].to_date.to_s + "'
        AND pp.blockweekly =0
        AND ppd.part_person_id = pp.id
        AND ppd.worker_id = w.id
        AND w.id = wc.worker_id
        AND wc.article_id = ar.id
        GROUP BY ar.name
      ")
      @names << inter[0].to_s+" ("+inter[1].to_time.strftime("%d/%m")+" - "+inter[2].to_time.strftime("%d/%m")+")"  
    end
    @names = @names.join(",")
    @theweek = @names.to_s
    @catehh = Array.new
    @catecp = Array.new
    @weekhh.each do |a|
      a.each do |b|
        @catehh << b[0]
        @catecp << b[0]
      end
    end
    @catehh = @catehh.uniq
    @catecp = @catecp.uniq
    
    @catwh = Array.new
    @catwp = Array.new
    @catehh.each do |cat|
      @weeks.each do |w|
        catwh = ActiveRecord::Base.connection.execute("
          SELECT SUM(ppd.total_hours)
          FROM part_people pp, part_person_details ppd, workers w, worker_contracts wc, articles ar
          WHERE pp.cost_center_id = "+@costcenter.to_s+"
          AND pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly =0
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          AND ar.name = '"+cat.to_s+"'
          GROUP BY ar.name
        ")
        catwp = ActiveRecord::Base.connection.execute("
          SELECT SUM(1)
          FROM part_people pp, part_person_details ppd, workers w, worker_contracts wc, articles ar
          WHERE pp.cost_center_id = "+@costcenter.to_s+"
          AND pp.date_of_creation BETWEEN '"+w[1].to_date.to_s+"' AND '"+w[2].to_date.to_s+"'
          AND pp.blockweekly =0
          AND ppd.part_person_id = pp.id
          AND ppd.worker_id = w.id
          AND w.id = wc.worker_id
          AND wc.article_id = ar.id
          AND ar.name = '"+cat.to_s+"'
          GROUP BY pp.date_of_creation
        ")
        if catwh.count==1
          catwh.each do |c|
            @catwh << c[0].to_f
          end
        else
          @catwh<<0
        end
        @max = 0
        if catwp.count>0
          catwp.each do |c|
            if c[0].to_f > @max
              @max = c[0]
            end
          end
            @catwp <<  @max.to_f
        else
          @catwp<<0
        end
      end
    end

    # GLOBAL Variables
    type = 'column'
    type2 = 'spline'

    @i=0
    @serieh = Array.new
    @seriep = Array.new

    @serie1 = Array.new
    @spline1 = Array.new
    @serie2 = Array.new
    @spline2 = Array.new

    @catehh.each do |c|
      f=@i+9
      @parteh = @catwh[@i.to_i..f.to_i]
      @serie1 << {
                  name: c,
                  type: type,
                  yAxis: 1,
                  data: @parteh
                }
      @spline1 << {
                  name: c,
                  type: type2,
                  yAxis: 1,
                  data: @parteh
                }
      @i+=10
    end
    @i2=0
    @catecp.each do |c|
      f=@i2+9
      @partep = @catwp[@i2.to_i..f.to_i]
      @serie2 << {
                  name: c,
                  type: type,
                  yAxis: 1,
                  data: @partep
                }
      @spline2 << {
                  name: c,
                  type: type2,
                  yAxis: 1,
                  data: @partep
                }
      @i2+=10
    end
    @serieh = @serie1 + @spline1
    @seriep = @serie2 + @spline2
    render(partial: 'graph', :layout => false)
  end

  def filter_array_business_days(array_order)
    reset_principal = 0
    while reset_principal == 0
      i = 0
      imax = array_order.count - 1
      reset = 0
      while i <= imax && reset == 0
          k = 0        
          repe = 0          
          while k <= imax && repe < 2
              if array_order[i][0] == array_order[k][0]
                  repe += 1                          
              end
              k += 1
          end
          if repe == 2   
              k = k - 1 
              sub_array_max = array_order[i][3].count - 1
              d = 0
              nuevo_total_horas_suma = 0
              while d <= sub_array_max
                array_order[i][3][d] = array_order[i][3][d].to_f + array_order[k][3][d].to_f
                nuevo_total_horas_suma += array_order[i][3][d]
                d += 1
              end
              array_order[i][4] = nuevo_total_horas_suma
              array_order[i][5] += array_order[k][5]
              array_order[i][6] += array_order[k][6]
              array_order[i][7] += array_order[k][7]                
              array_order.delete_at(k)
              reset += 1
          end                  
          i += 1
      end          
      if i == array_order.count
        reset_principal += 1
      end    
    end    
    return array_order.sort_by{|k| k[1]}    
  end

  private
  def weekly_table_parameters
    params.require(:weekly_worker).permit(:start_date, :end_date, :working_group)
  end
end