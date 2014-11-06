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
    @reg_n = ((Time.now.to_f)*100).to_i
    @concepts=Concept.where("type_concept like 'Fijo'")
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
      @workercontract = WorkerContract.new
      @workercontract2 = WorkerContract.find_by_worker_id(params[:worker_id])
      @worker_id = params[:worker_id]
      @worker = Worker.find_by_id(@worker_id)
      @workercontract.camp = @workercontract2.camp.to_f
      @workercontract.destaque = @workercontract2.destaque.to_f
      @workercontract.salary = @workercontract2.salary.to_f
      @workercontract.regime = @workercontract2.regime.to_s
      @workercontract.days = @workercontract2.days.to_i
      @workercontract.bonus = @workercontract2.bonus.to_f
      @workercontract.article_id = @workercontract2.article_id.to_i
      @workercontract.contract_type_id = @workercontract2.contract_type_id.to_i
      @workercontract.viatical = @workercontract2.viatical.to_i
      @workercontract.start_date = @workercontract2.start_date
      @workercontract.end_date = @workercontract2.end_date
      if WorkerContract.where("worker_id = ? AND typeofcontract LIKE 'Adenda'",params[:worker_id]).count > 0
        @numberofcontract = @workercontract2.numberofcontract
        @numberofcontract = @numberofcontract + ' - AD ' + (WorkerContract.where("worker_id = ? AND typeofcontract LIKE 'Adenda'",params[:worker_id]).count + 1).to_s.rjust(2, '0')
      else
        @numberofcontract = @workercontract2.numberofcontract + ' - AD 01'
      end
    end
    if @typeofcontract == 'Renovacion'
      @workercontract = WorkerContract.new
      @workercontract2 = WorkerContract.find_by_worker_id(params[:worker_id])
      @worker_id = params[:worker_id]
      @worker = Worker.find_by_id(@worker_id)
      @workercontract.camp = @workercontract2.camp.to_f
      @workercontract.destaque = @workercontract2.destaque.to_f
      @workercontract.salary = @workercontract2.salary.to_f
      @workercontract.regime = @workercontract2.regime.to_s
      @workercontract.days = @workercontract2.days.to_i
      @workercontract.bonus = @workercontract2.bonus.to_f
      @workercontract.article_id = @workercontract2.article_id.to_i
      @workercontract.contract_type_id = @workercontract2.contract_type_id.to_i
      @workercontract.viatical = @workercontract2.viatical.to_i
      @diff = (@workercontract2.end_date - @workercontract2.start_date).to_i
      @workercontract.start_date = @workercontract2.end_date.to_date + 1.days
      @workercontract.end_date = @workercontract2.end_date.to_date + @diff.days
      if WorkerContract.where("worker_id = ? AND typeofcontract LIKE 'Renovacion'",params[:worker_id]).count > 0
        @numberofcontract = @workercontract2.numberofcontract
        @numberofcontract = @numberofcontract + ' - RVN ' + (WorkerContract.where("worker_id = ? AND typeofcontract LIKE 'Renovacion'",params[:worker_id]).count + 1).to_s.rjust(2, '0')
      else
        @numberofcontract = @workercontract2.numberofcontract + ' - RVN 01'
      end
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
      #cat = CategoryOfWorker.find_by_article_id(workercontract.article_id)
      #if !cat.nil?
        #ActiveRecord::Base.connection.execute("INSERT INTO category_of_workers (article_id) VALUES ("+ workercontract.article_id.to_i.to_s+")")
      #end
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
    @reg_n = ((Time.now.to_f)*100).to_i
    @concepts=Concept.where("type_concept like 'Fijo'")
    @workercontract = WorkerContract.find(params[:id])
    @id=params[:id]
    @worker = Worker.find_by_id(@workercontract.worker_id)
    @articles = TypeOfArticle.find_by_code('01').articles
    @contractypes = ContractType.all
    @cost_center = session[:cost_center]
    @typeofcontract = params[:typeofcontract]
    @action = 'edit'
    @worker_id = @workercontract.worker_id
    render layout: false
  end

  def display_articles_personal
    word = params[:q]
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    articles = Article.get_article_todo_per_type(word, get_company_cost_center('cost_center'), '01')
    articles.each do |art|
      article_hash << {'id' => art[0].to_s, 'code' => art[2], 'name' => art[1], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def update
    workercontract = WorkerContract.find(params[:id])
    if workercontract.update_attributes(worker_contract_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      #cat = CategoryOfWorker.find_by_article_id(workercontract.article_id)
      #if cat.nil?
        #ActiveRecord::Base.connection.execute("INSERT INTO category_of_workers (article_id) VALUES ("+ workercontract.article_id.to_i.to_s+")")
      #end
      redirect_to :action => :index, worker_id: workercontract.worker_id
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
    params.require(:worker_contract).permit(:camp, :lock_version, :contract_type_id, :article_id, :destaque, :salary, :regime, :bonus, :viatical, :days, :start_date, :end_date, :worker_id, :numberofcontract, :typeofcontract, worker_contract_details_attributes:[:id, :worker_id,:worker_contract_id,:concept_id,:amount, :_destroy])
  end
end
