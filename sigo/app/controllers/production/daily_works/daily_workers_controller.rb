class Production::DailyWorks::DailyWorkersController < ApplicationController
  def index
    @workingGroups = WorkingGroup.all
    render layout: false
  end

  def search_daily_work
    @company = params[:company_id]
    if params[:working_group] != nil
      @working_group = WorkingGroup.find(params[:working_group])
    else
      @working_group = WorkingGroup.all
    end
    start_date = params[:start_date]
    end_date = params[:end_date]
    @business_days = range_business_days(start_date, end_date)
    @workers_array = business_days_array(start_date, end_date, params[:working_group])
    render(partial: 'daily_table', :layout => false)
  end

  # Functions for show Table Summarize

  def range_business_days(start_date, end_date)
    start_date_var = start_date.to_date
    end_date_var = end_date.to_date
    business_days = []
    while end_date_var >= start_date_var
      business_days << start_date_var.strftime("%d/%m/%Y")
      start_date_var = start_date_var + 1.day
    end
    return business_days
  end

  def business_days_array(start_date, end_date, working_group_id)
    #worker_ids_array = []
    #daily_work_people = PartPerson.where("working_group_id = ? and date_of_creation BETWEEN ? AND ?", gruposdetrabajo_id,inicio,fin)
    
    #daily_work_people.each do |daily_work_person|
      #daily_work_person.part_person_details.each do |daily_work_person_detail|
        #worker_ids_array << daily_work_person_detail.worker_id
        #worker_ids_array = worker_ids_array.select { |e| worker_ids_array.count(e) > 0 }.uniq
      #end
    #end

    workers_array = ActiveRecord::Base.connection.execute("
      SELECT  CONCAT( w.paternal_surname,  ' ', w.maternal_surname,  ' ', w.first_name,  ' ', w.second_name ) AS name, 
        cow.name AS category,
        SUM( ppd.normal_hours ) AS normal_hours, 
        SUM( ppd.he_60 ) AS he_60, 
        SUM( ppd.he_100 ) AS he_100, 
        SUM( ppd.total_hours ) AS total_hours, 
        p.date_of_creation 
      FROM part_people p, part_person_details ppd, workers w, category_of_workers cow
      WHERE p.working_group_id = " + working_group_id + "
      AND p.date_of_creation BETWEEN '" + start_date + "' AND '" + end_date + "'
      AND p.id = ppd.part_person_id 
      AND ppd.worker_id = w.id
      AND w.category_of_worker_id = cow.id
      GROUP BY ppd.worker_id
    ")

    return workers_array
  end

end
