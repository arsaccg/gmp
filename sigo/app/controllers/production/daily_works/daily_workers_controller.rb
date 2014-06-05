class Production::DailyWorks::DailyWorkersController < ApplicationController
  def index
    @workingGroups = WorkingGroup.all
    render layout: false
  end

  # Functions for show Table Summarize

  def search_daily_work
    @gruposdetrabajo_id     = params[:working_group]      
    @inicio             = params[:start_date]      
    @fin                = params[:end_date]

    if @gruposdetrabajo_id.present? && @inicio.present? && @fin.present?
      @dias_habiles =  range_business_days(@inicio,@fin)
      @trabajadores_array = business_days_array(@inicio,@fin,@gruposdetrabajo_id,@dias_habiles)
      gruposdetrabajo = WorkingGroup.find_by_id(@gruposdetrabajo_id)
      @subcontratista_nombre = "#{gruposdetrabajo.name} - #{Entity.find(Worker.find(gruposdetrabajo.front_chief_id).entity_id).name} - #{Entity.find_name_executor(gruposdetrabajo.executor_id)} - #{Entity.find(Worker.find(gruposdetrabajo.master_builder_id).entity_id).name}"

      if @trabajadores_array.length != 0
        @pase = 1
        puts @pase
        render(partial: 'daily_table', :layout => false)
      else
        @pase = 2
        render(partial: 'daily_table', :layout => false)
      end

    elsif @gruposdetrabajo_id.blank? && @inicio.present? && @fin.present?
      @dias_habiles =  range_business_days(@inicio,@fin)
      gruposdetrabajos = WorkingGroup.all
      @tareos_total_arrays = []
      @subcontratista_arrays = []
      gruposdetrabajos.each do |gruposdetrabajo|
        temp_tareo = []
        temp_tareo = business_days_array(@inicio,@fin,gruposdetrabajo.id,@dias_habiles)          
        if temp_tareo.length != 0 
          @tareos_total_arrays << temp_tareo
          subcontratista_nombre = "#{gruposdetrabajo.name} - #{Entity.find(Worker.find(gruposdetrabajo.front_chief_id).entity_id).name} - #{Entity.find_name_executor(gruposdetrabajo.executor_id)} - #{Entity.find(Worker.find(gruposdetrabajo.master_builder_id).entity_id).name}"
          @subcontratista_arrays << subcontratista_nombre
        end
      end

      if @tareos_total_arrays.length != 0
        @pase = 4
        render(partial: 'daily_table', :layout => false)
      else
        @pase = 2
        render(partial: 'daily_table', :layout => false)
      end
    else
      @pase = 3
      render(partial: 'daily_table', :layout => false)
    end
  end

  def search_weekly_work
    @weekly_worker = WeeklyWorker.new
    @inicio                = params[:start_date]
    @fin                   = params[:end_date]
    @cad = Array.new
    if @inicio.present? && @fin.present?        
      @dias_habiles =  range_business_days(@inicio,@fin)
      @gruposdetrabajos = WorkingGroup.all
      @gruposdetrabajos.each do |wg|
        @cad << wg.id
      end
      @tareos_total_arrays = []
      @subcontratista_arrays = []
      @gruposdetrabajos.each do |gruposdetrabajo|
        temp_tareo = []
        temp_tareo = business_days_array(@inicio,@fin,@cad,@dias_habiles)          
        if temp_tareo.length != 0 
          @tareos_total_arrays << temp_tareo
          subcontratista_nombre = "#{gruposdetrabajo.name} - #{Entity.find(Worker.find(gruposdetrabajo.front_chief_id).entity_id).name} - #{Entity.find_name_executor(gruposdetrabajo.executor_id)} - #{Entity.find(Worker.find(gruposdetrabajo.master_builder_id).entity_id).name}"
          @subcontratista_arrays << subcontratista_nombre
        end
        break
      end

      if @dias_habiles.length == 0
        @pase = 3
        render(partial: 'weekly_table', :layout => false)
      else
        if @tareos_total_arrays.length != 0
          @pase = 4
          render(partial: 'weekly_table', :layout => false)
        else
          @pase = 2
          render(partial: 'weekly_table', :layout => false)
        end
      end
    else 
      @pase = 3
      render(partial: 'weekly_table', :layout => false)
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

  def business_days_array(start_date, end_date, working_group_id, business_days)

    personals_array = []
    trabajadores_array = []
    partediariodepersonals = PartPerson.where("working_group_id IN (?) and date_of_creation BETWEEN ? AND ?", working_group_id,start_date,end_date)
    partediariodepersonals.each do |partediariodepersonal|
      partediariodepersonal.part_person_details.each do |trabajador_detalle|
        trabajadore = trabajador_detalle.worker
        id = trabajadore.id
        nombre = "#{trabajadore.entity.paternal_surname + ' ' + trabajadore.entity.maternal_surname}, #{trabajadore.entity.name}  #{trabajadore.entity.second_name}"
        categoria = "#{trabajadore.article.name}"              
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
end
