class Production::WorkerContractsController < ApplicationController
	before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @worker_id = 2
    @company = get_company_cost_center('company')
    #@own_cost_center = current_user.cost_centers
    @workercontracts = WorkerContract.where("worker_id = ?", @worker_id)
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
  	@worker_id = params[:worker_id]
    @workercontract = WorkerContract.new
    @cost_center = session[:cost_center]
    @charges = Charge.all
    @typeofcontract = 'Contrato'
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    workercontract = WorkerContract.new(worker_contract_parameters)
    workercontract.end_date_2 = params[:worker_contract]['end_date']
    if workercontract.save
      flash[:notice] = "Se ha creado correctamente el contrato."
      redirect_to :action => :index
    else
      workercontract.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      render :new, layout: false
    end
        
  end

  def edit
    @costCenter = CostCenter.find(params[:id])
    @companies = Company.all
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])

    if params[:timeline] == nil
      # Save Maintenance
      if costCenter.update_attributes(cost_center_parameters)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
      end
    else
      # Save TimeLine by Start Date / End Date
      if costCenter.update_attributes(cost_center_parameters_timeline)
        CostCenterTimeline.LoadTimeLine(costCenter.id, costCenter.start_date, costCenter.end_date)

        flash[:notice] = "Se actualizó la duración del proyecto."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
      end
    end
  end

  def destroy
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])
    if costCenter.update_attributes({status: "D"})#, user_updates_id: params[:current_user_id]})
      flash[:notice] = "Se ha eliminado correctamente."
      render :json => {notice: flash[:notice]}
    else
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :json => {error: flash[:error]}
    end
  end

  private
  def worker_contract_parameters
    params.require(:worker_contract).permit(:position_of_worker, :camp, :destaque, :salary, :regime, :days, :start_date, :end_date, :worker_id, :numberofcontract, :typeofcontract)
  end
end
