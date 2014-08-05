class Production::WorkerContractsController < ApplicationController
	before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @worker_id = params[:worker_id]
    @company = get_company_cost_center('company')
    @worker = Worker.find_by_id(@worker_id)
    #@own_cost_center = current_user.cost_centers
    @workercontracts = WorkerContract.where("worker_id = ?", @worker_id)
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @typeofcontract = params[:typeofcontract]
    @articles = TypeOfArticle.find_by_code('01').articles
    @contractypes = ContractType.all
    @cost_center = session[:cost_center]
    if @typeofcontract == 'Contrato'
      @workercontract = WorkerContract.new
    	@worker_id = params[:worker_id]
      @worker = Worker.find_by_id(@worker_id)
    end
    if @typeofcontract == 'Adenda'
      @action = 'edit'
      @workercontract = WorkerContract.find_by_id(params[:contract])
      @worker_id = @workercontract.worker_id
      @worker = Worker.find_by_id(@worker_id)
    end
    if @typeofcontract == 'Renovacion'
      @action = 'edit'
      @workercontract = WorkerContract.find_by_id(params[:contract])
      @worker_id = @workercontract.worker_id
      @diff = (@workercontract.end_date - @workercontract.start_date).to_i
      @workercontract.start_date = @workercontract.end_date.to_date + 1.days
      @workercontract.end_date = @workercontract.end_date.to_date + @diff.days
      @worker = Worker.find_by_id(@worker_id)
    end
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    workercontract = WorkerContract.new(worker_contract_parameters)
    workercontract.end_date_2 = params[:worker_contract]['end_date']
    workercontract.status = 1
    if workercontract.save
      flash[:notice] = "Se ha creado correctamente el contrato."
      @worker = Worker.find_by_id(params[:worker_contract]['worker_id'])
      @worker.approve
      redirect_to :action => :index, worker_id: params[:worker_contract]['worker_id']
    else
      workercontract.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      render :new, layout: false
    end
        
  end

  def edit
    @workercontract = WorkerContract.find(params[:id])
    @worker = Worker.find_by_id(@workercontract.worker_id)
    @articles = TypeOfArticle.find_by_code('01').articles
    @contractypes = ContractType.all
    @cost_center = session[:cost_center]
    @action = 'edit'
    @worker_id = @workercontract.worker_id
    render layout: false
  end

  def update
    workercontract = WorkerContract.find(params[:id])
    workercontract2 = WorkerContract.new(worker_contract_parameters)
    workercontract2.end_date_2 = params[:worker_contract]['end_date']
    workercontract2.status = 1
    if workercontract.update_attributes({end_date_2: (params[:worker_contract]['start_date'].to_date - 1.days), status: 0}) && workercontract2.save
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, worker_id: params[:worker_contract]['worker_id']
    else
      workercontract.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @workercontract = workercontract
      render :edit, layout: false
    end
  end

  def destroy
    workercontract = WorkerContract.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Contrato."
    render :json => workercontract
  end

  private
  def worker_contract_parameters
    params.require(:worker_contract).permit(:camp, :contract_type_id, :article_id, :destaque, :salary, :regime, :bonus, :viatical, :days, :start_date, :end_date, :worker_id, :numberofcontract, :typeofcontract)
  end
end
