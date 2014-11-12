class Payrolls::PayslipsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @pay = Payroll.all
    @ids = Array.new
    contracts = WorkerContract.where("start_date < '"+Time.now.strftime("%YYYY-%mm-%dd").to_s+"' AND end_date > '"+Time.now.strftime("%YYYY-%mm-%dd").to_s+"'")
    contracts.each do |con|
      @ids << con.worker_id
    end
    @ids = @ids.join(',')
    render layout: false
  end

  def show
    @pay = Payroll.find_by_worker_id(params[:id])
    @type = params[:type]
    if !@pay.nil?
      @payroll_details = @pay.payroll_details
    end
    @worker = Worker.find(params[:id])
    @entity =Entity.find(@worker.entity_id)
    render layout: false
  end

  def new
    @pay = Payslip.new 
    @ing = Array.new
    @des = Array.new
    @ingresos = Concept.where("code LIKE '1%' AND type_obrero = 'Fijo'")
    @descuentos = Concept.where("code LIKE '2%' AND type_obrero = 'Fijo'")
    @company = Company.all
    @afp = Afp.all
    @years = Array.new
    (2000..2050).each do |x|
      @years << x
    end
    @ingresos.each do |ing|
      @ing << ing.id.to_s
    end
    @descuentos.each do |des|
      @des << des.id.to_s
    end
    render layout: false
  end

  def get_cc
    @cc = Company.find(params[:company]).cost_centers
    render json: {:cc=>@cc}  
  end

  def get_sem
    periodo = params[:periodo].split('-')
    @mes = periodo[1]
    @año = periodo[0]
    @dia = 0
    if @mes%2==0 && @mes!=8
      if @mes==2
        if @año%4 == 0
          @dia = 29
        else
          @dia = 28
        end
      else
        @dia = 30
      end
    else
      @dia = 31
    end
    @fechai = @año.to_s+"-"+@mes.to_s+"-"+"01"
    @fechaf = @año.to_s+"-"+@mes.to_s+"-"+@dia.to_s
    semana = ActiveRecord::Base.connection.execute("
      SELECT w.name, w.id
      FROM weeks_for_cost_center_" + params[:cc].to_s + " w
      WHERE w.end_date BETWEEN '"+ @fechai.to_s+"' AND '"+@fechaf.to_s+"'
    ")
    puts semana.to_a.inspect
    render json: {:semana=>semana.to_a}
  end  

  def create
    flash[:error] = nil
    pay = Payroll.new(pay_parameters)
    pay.status = 1
    if pay.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      pay.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @pay = pay
      render :new, layout: false 
    end
  end

  def edit
    @pay = Payroll.find_by_worker_id(params[:id])
    @ing = Array.new
    @des = Array.new
    @worker = Worker.find(params[:id])
    @entity =Entity.find(@worker.entity_id)
    @ingresos = Concept.where("code LIKE '1%' AND type_concept = 'Fijo'")
    @descuentos = Concept.where("code LIKE '2%' AND type_concept = 'Fijo'")
    @ingresos.each do |ing|
      @ing << ing.id.to_s
    end
    @descuentos.each do |des|
      @des << des.id.to_s
    end    
    @action = 'edit'
    @reg_n = (Time.now.to_f*1000).to_i
    render layout: false
  end

  def update
    pay = Payroll.find(params[:id])
    if pay.update_attributes(pay_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      pay.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @pay = pay
      render :edit, layout: false
    end
  end

  def destroy
    pay = Payroll.find(params[:id])
    ActiveRecord::Base.connection.execute("
          UPDATE payrolls SET
          status = 0
          WHERE id = "+pay.id.to_s+"
        ")
    render :json => pay
  end

  private
  def pay_parameters
    params.require(:payroll).permit(:worker_id, 
      payroll_details_attributes: [
        :id, 
        :payroll_id, 
        :concept_id, 
        :amount, 
        :type_con,
        :_destroy
      ] )
  end
end