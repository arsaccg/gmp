class Production::DailyWorks::ScheduleOfWorkersController < ApplicationController
  def index
    render layout: false
  end
  def new
    render layout: false
  end

  # Functions for show Table Summarize

  def search_schedule_work
    @company = Company.find(session[:company])
    @cost_center = CostCenter.find(session[:cost_center])
    @inicio = params[:start_date]
    @fin = params[:end_date]
    @dias_habiles =  range_business_days(@inicio,@fin)
    workers = Array.new
    @arraywo = Array.new
    partworkers = PartWorker.where("date_of_creation BETWEEN ? AND ?",@inicio,@fin)
    partworkers.each do |pw|
      pw.part_worker_details.each do |pwd|
        workers << pwd.worker_id
      end
    end
    workers = workers.uniq
    workers = workers.sort
    index = 1
    valor = 0
    workers.each do |wo|
      totalworker = 0
      wor = Worker.find(wo)
      contract = WorkerContract.where("worker_id = ?",wo).last
      cadenita = index.to_s + ',' + contract.article.code.to_s + ',' + contract.article.name.to_s + ',' + wor.entity.dni.to_s + ',' + wor.entity.paternal_surname.to_s + ',' + wor.entity.maternal_surname.to_s + ',' + wor.entity.name.to_s + ',' + wor.entity.second_name.to_s
      @dias_habiles.each do |dh|
        answer = PartWorker.find_by_date_of_creation(dh)
        if answer.nil?
          cadenita = cadenita + ',' + '0'
        else
          answer2 = PartWorkerDetail.where("part_worker_id = ? AND worker_id = ?", answer.id, wo)
          if answer2.count == 0
            cadenita = cadenita + ',' + '0'
          end
          answer2.each do |ans2|
            if ans2.assistance == 'si'
              cadenita = cadenita + ',' + '1'
              totalworker +=1
            else
              cadenita = cadenita + ',' + '0'
            end
          end
        end
      end
      cadenita = cadenita + ',' + totalworker.to_s
      @arraywo << cadenita.split(',')
      index += 1
    end
    @totalperday = Array.new
    totaltotal = 0
    @dias_habiles.each do |dh|
      perday = PartWorker.find_by_date_of_creation(dh)
      day = PartWorkerDetail.where("part_worker_id = ? AND assistance LIKE 'si'", perday.id)
      @totalperday << day.count.to_s
      totaltotal = totaltotal + day.count
    end
    @totalperday << totaltotal
    render(partial: 'schedule_table', :layout => false)
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
end