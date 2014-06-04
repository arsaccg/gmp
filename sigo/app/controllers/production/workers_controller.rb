class Production::WorkersController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @article = TypeOfArticle.find_by_code('01').articles.first
    @bank = Bank.first
    @workers = Worker.where("cost_center_id = ?", cost_center)
    render layout: false
  end

  def show
    @worker = Worker.find(params[:id])
    render layout: false
  end

  def new
    @worker = Worker.new
    @articles = TypeOfArticle.find_by_code('01').articles
    @positionWorkers = PositionWorker.all
    @company = params[:company_id]
    @banks = Bank.all
    render layout: false
  end

  def create
    worker = Worker.new(worker_parameters)
    worker.cost_center_id = get_company_cost_center('cost_center')
    if worker.save
      categoryOfWorker = CategoryOfWorker.new
      if CategoryOfWorker.find_by_article_id(worker.article_id).blank?
        categoryOfWorker.article_id = worker.article_id
        categoryOfWorker.save
      end

      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @worker = Worker.find(params[:id])
    @banks = Bank.all
    @reg_n = Time.now.to_i
    @articles = TypeOfArticle.find_by_code('01').articles
    @positionWorkers = PositionWorker.all
    @company = params[:company_id]
    @action = 'edit'
    render layout: false
  end

  def update
    worker = Worker.find(params[:id])
    if worker.update_attributes(worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @worker = worker
      render :edit, layout: false
    end
  end

  def add_worker_item_field
    @reg_n = ((Time.now.to_f)*100).to_i
    data_bank_unit = params[:bank_id].split('-')
    @bank = Bank.find(data_bank_unit[0])
    @account_number = params[:account_number].to_f
    @business_name_bank, @id_bank = @bank.business_name, @bank.id
    render(partial: 'worker_items', :layout => false)
  end

  def destroy
    worker = Worker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el trabajador."
    render :json => worker
  end

  private
  def worker_parameters
    params.require(:worker).permit(:first_name, :paternal_surname, :maternal_surname, :dni, :email, :phone, :date_of_birth, :address, :article_id, :second_name, :position_worker_id, worker_details_attributes: [:id, :worker_id, :bank_id, :account_number, :_destroy])
  end
end