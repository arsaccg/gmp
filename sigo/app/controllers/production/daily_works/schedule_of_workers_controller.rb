class Production::DailyWorks::ScheduleOfWorkersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update, :graph ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @schedule = ScheduleOfWorker.where(:cost_center_id => get_company_cost_center('cost_center'))
    render layout: false
  end

  def show
    @schedule = ScheduleOfWorker.find(params[:id])
    @inicio = @schedule.start_date
    @type = params[:type]
    @fin = @schedule.end_date
    @company = Company.find(get_company_cost_center('company'))
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @dias_habiles =  range_business_days(@inicio,@fin)
    workers = Array.new
    @arraywo = Array.new
    partworkers = PartWorker.where("date_of_creation BETWEEN ? AND ? AND blockweekly = 1",@inicio,@fin)
    partworkers.each do |pw|
      pw.part_worker_details.each do |pwd|
        workers << pwd.worker_id
      end
    end

    workers = workers.uniq
    workers = workers.sort
    index = 1
    valor = 0

    @part_worker_to_block = Array.new
    workers.each do |wo|
      totalworker = 0
      wor = Worker.find(wo)
      contract = WorkerContract.where("worker_id = ? AND status = 1",wo).first
      cadenita = index.to_s + ';' + contract.article.code.to_s + ';' + contract.article.name.to_s + ';' + wor.entity.dni.to_s + ';' + wor.entity.paternal_surname.to_s + " " + wor.entity.maternal_surname.to_s + ', ' + wor.entity.name.to_s + ' ' + wor.entity.second_name.to_s
      @dias_habiles.each do |dh|
        answer = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 1").first
        if answer.nil?
          cadenita = cadenita + ';' + '0'
        else
          answer2 = PartWorkerDetail.where("part_worker_id = ? AND worker_id = ?", answer.id, wo)
          if answer2.count == 0
            cadenita = cadenita + ';' + '0'
          end
          answer2.each do |ans2|
            if ans2.assistance == 'si'
              cadenita = cadenita + ';' + '1'
              totalworker +=1
              @part_worker_to_block << answer.id
            else
              cadenita = cadenita + ';' + '0'
            end
          end
        end
      end
      cadenita = cadenita + ';' + totalworker.to_s
      @arraywo << cadenita.split(';')
      index += 1
    end
    @totalperday = Array.new
    totaltotal = 0
    @dias_habiles.each do |dh|
      perday = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 1").first
      if !perday.nil?
        day = PartWorkerDetail.where("part_worker_id = ? AND assistance LIKE 'si'", perday.id)
        @totalperday << day.count.to_s
        totaltotal = totaltotal + day.count
      else
        @totalperday << 0
      end

    end
    @totalperday << totaltotal
    @part_worker_to_block = @part_worker_to_block.uniq.join(',')
    render layout: false
  end

  def new
    render layout: false
  end 

  def create
    weekly_worker = ScheduleOfWorker.new(schedule_of_workers_parameters)
    ids_part = params[:block_part]
    if weekly_worker.save
      ActiveRecord::Base.connection.execute("UPDATE part_workers SET blockweekly = 1 WHERE id IN ("+ids_part.to_s+")")
      redirect_to :action => :index, company_id: params[:company_id]
    else
      weekly_worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def destroy
    schedule = ScheduleOfWorker.find(params[:id])
    ActiveRecord::Base.connection.execute("UPDATE part_workers SET blockweekly = 0 WHERE date_of_creation BETWEEN '"+schedule.start_date.to_s+"' AND '"+schedule.end_date.to_s+"' AND blockweekly = 1")
    flash[:notice] = "Se ha eliminado correctamente el tareo."
    schedule = ScheduleOfWorker.destroy(params[:id])
    render :json => schedule
  end

  def approve
    ScheduleOfWorker.find(params[:id]).update(:state=>"approved")
    ActiveRecord::Base.connection.execute("UPDATE part_workers SET blockpayslip = 1 WHERE id IN ("+params[:parts].to_s+")")
    redirect_to :action => :index
  end

  def report_pdf
    respond_to do |format|
      format.html
      format.pdf do
        @schedule = ScheduleOfWorker.find(params[:id])
        @inicio = @schedule.start_date
        @fin = @schedule.end_date
        @company = Company.find(get_company_cost_center('company'))
        @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
        @dias_habiles =  range_business_days(@inicio,@fin)
        workers = Array.new
        @arraywo = Array.new
        partworkers = PartWorker.where("date_of_creation BETWEEN ? AND ? AND blockweekly = 1",@inicio,@fin)
        partworkers.each do |pw|
          pw.part_worker_details.each do |pwd|
            workers << pwd.worker_id
          end
        end

        workers = workers.uniq
        workers = workers.sort
        index = 1
        valor = 0

        @part_worker_to_block = Array.new
        workers.each do |wo|
          totalworker = 0
          wor = Worker.find(wo)
          contract = WorkerContract.where("worker_id = ? AND status = 1",wo).first
          puts "------------------------------------------------------------------------------------------------------------------------------------------------"
          p wo.inspect
          puts "------------------------------------------------------------------------------------------------------------------------------------------------"
          p contract.inspect
          puts "------------------------------------------------------------------------------------------------------------------------------------------------"          
          cadenita = index.to_s + ';' + contract.article.code.to_s + ';' + contract.article.name.to_s + ';' + wor.entity.dni.to_s + ';' + wor.entity.paternal_surname.to_s + " " + wor.entity.maternal_surname.to_s + ', ' + wor.entity.name.to_s + ' ' + wor.entity.second_name.to_s
          @dias_habiles.each do |dh|
            answer = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 1").first
            if answer.nil?
              cadenita = cadenita + ';' + '0'
            else
              answer2 = PartWorkerDetail.where("part_worker_id = ? AND worker_id = ?", answer.id, wo)
              if answer2.count == 0
                cadenita = cadenita + ';' + '0'
              end
              answer2.each do |ans2|
                if ans2.assistance == 'si'
                  cadenita = cadenita + ';' + '1'
                  totalworker +=1
                  @part_worker_to_block << answer.id
                else
                  cadenita = cadenita + ';' + '0'
                end
              end
            end
          end
          cadenita = cadenita + ';' + totalworker.to_s
          @arraywo << cadenita.split(';')
          index += 1
        end
        @totalperday = Array.new
        totaltotal = 0
        @dias_habiles.each do |dh|
          perday = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 1").first
          if !perday.nil?
            day = PartWorkerDetail.where("part_worker_id = ? AND assistance LIKE 'si'", perday.id)
            @totalperday << day.count.to_s
            totaltotal = totaltotal + day.count
          else
            @totalperday << 0
          end

        end
        @totalperday << totaltotal
        @part_worker_to_block = @part_worker_to_block.uniq.join(',')
        render :pdf => "reporte-#{Time.now.strftime('%d-%m-%Y')}", 
         :template => 'production/daily_works/schedule_of_workers/report_pdf.pdf.haml',
         :orientation => 'Landscape',
         :page_size => 'A2'
       end
    end
  end
  # Functions for show Table Summarize

  def search_schedule_work
    @schedule = ScheduleOfWorker.new
    @company = Company.find(session[:company])
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @inicio = params[:start_date]
    @fin = params[:end_date]

    @dias_habiles =  range_business_days(@inicio,@fin)
    workers = Array.new
    @arraywo = Array.new
    partworkers = PartWorker.where("date_of_creation BETWEEN ? AND ? AND blockweekly = 0",@inicio,@fin)
    partworkers.each do |pw|
      pw.part_worker_details.each do |pwd|
        workers << pwd.worker_id
      end
    end

    puts "................................................................................................................................................"
    p partworkers.inspect
    p workers.inspect
    puts "................................................................................................................................................"

    workers = workers.uniq
    workers = workers.sort
    index = 1
    valor = 0

    @part_worker_to_block = Array.new
    workers.each do |wo|
      totalworker = 0
      wor = Worker.find(wo)
      contract = WorkerContract.where("worker_id = ? AND status = 1",wo).first
      puts "------------------------------------------------------------------------------------------------------------------------------------------------"
      p wo.inspect
      puts "------------------------------------------------------------------------------------------------------------------------------------------------"
      p contract.inspect
      puts "------------------------------------------------------------------------------------------------------------------------------------------------"
      cadenita = index.to_s + ';' + contract.article.code.to_s + ';' + contract.article.name.to_s + ';' + wor.entity.dni.to_s + ';' + wor.entity.paternal_surname.to_s + " " + wor.entity.maternal_surname.to_s + ', ' + wor.entity.name.to_s + ' ' + wor.entity.second_name.to_s
      @dias_habiles.each do |dh|
        answer = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 0").first
        if answer.nil?
          cadenita = cadenita + ';' + '0'
        else
          answer2 = PartWorkerDetail.where("part_worker_id = ? AND worker_id = ?", answer.id, wo)
          if answer2.count == 0
            cadenita = cadenita + ';' + '0'
          end
          answer2.each do |ans2|
            if ans2.assistance == 'si'
              cadenita = cadenita + ';' + '1'
              totalworker +=1
              @part_worker_to_block << answer.id
            else
              cadenita = cadenita + ';' + '0'
            end
          end
        end
      end
      cadenita = cadenita + ';' + totalworker.to_s
      @arraywo << cadenita.split(';')
      index += 1
    end
    @totalperday = Array.new
    totaltotal = 0
    @dias_habiles.each do |dh|
      perday = PartWorker.where("date_of_creation = '"+dh.to_s+"' and blockweekly = 0").first
      if !perday.nil?
        day = PartWorkerDetail.where("part_worker_id = ? AND assistance LIKE 'si'", perday.id)
        @totalperday << day.count.to_s
        totaltotal = totaltotal + day.count
      else
        @totalperday << 0        
      end
    end
    @totalperday << totaltotal
    @part_worker_to_block = @part_worker_to_block.uniq.join(',')
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


  private
  def schedule_of_workers_parameters
    params.require(:schedule_of_worker).permit(:start_date, :end_date, :cost_center_id, :number_workers, :state)
  end
end