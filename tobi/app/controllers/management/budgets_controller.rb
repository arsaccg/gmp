class Management::BudgetsController < ApplicationController
  

  def index
  	@budgets_goal = Budget.where(:type_of_budget => '0')
  	@budgets_sale = Budget.where(:type_of_budget => '1')
    respond_to do |format|
      format.json { render :json => Budget.all.to_json }
    end
  end

  def get_budget_by_project
    @project_id = params[:project_id]
    @budgets_goal = Budget.where("type_of_budget = ? AND cost_center_id = ? ", '0', @project_id)
    @budgets_sale = Budget.where("type_of_budget = ? AND cost_center_id = ? ", '1', @project_id) 
    render :get_budget_by_project, layout: false
  end
  
  def display_articles
    word = params[:q]
    article_hash = Array.new
    articles = ActiveRecord::Base.connection.execute("SELECT a.id, a.code, a.name, a.unit_of_measurement_id, u.symbol FROM articles a, unit_of_measurements u WHERE a.code LIKE '04%' AND ( a.name LIKE '%#{word}%' OR a.code LIKE '%#{word}%' ) AND a.unit_of_measurement_id = u.id")
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def new
  	@budget = Budget.new
  	@dbs = @budget.load_dbs
  	render :new, layout: false
  end

  def show
  end

  def get_budgets
    @budget = Budget.new
    @budget = @budget.load_bugdets_from_remote(params[:database])
    respond_to do |format|
      format.json { render :json => @budget.to_json }
    end
  end

  def destroy
    
    budget=Budget.find(params[:id])

    project_id = budget.cost_center_id

    budgets = Budget.where("id LIKE ? and cost_center_id = ?", budget.id.to_s + "%", project_id.to_s)
    
    budgets.each do |budget_item|
      #Inputbybudgetanditem.where(budget_id: budget_item.id).destroy_all
      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM inputbybudgetanditems where budget_id='#{budget_item.id}'")
      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM itembybudgets where budget_id='#{budget_item.id}'")
      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM itembywbses where budget_id='#{budget_item.id}'")
      
    end
    
    budgets.destroy_all

    ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM budgets where cod_budget LIKE '#{budget.cod_budget}' and cost_center_id = '#{budget.cost_center_id}'")
    
    ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM items where budget_code LIKE '#{budget.cod_budget}' and cost_center_id = '#{budget.cost_center_id}'")

    #DESTROY

    @budgets_goal = Budget.where("type_of_budget = ? AND cost_center_id = ? ", '0', project_id)
    @budgets_sale = Budget.where("type_of_budget = ? AND cost_center_id = ? ", '1', project_id)
    render :get_budget_by_project, layout: false

  end

  def get_cookies
    respond_to do |format|
      format.json  { 
        render :json => [Pmicg.counter_global].to_json
      }

    end
  end

  def load_elements
  	budget_id = params[:budget_id]
  	project_id = params[:project_id]
  	type_of_budget  = params[:type_of_budget]
    database = params[:database]

  	budget = Budget.new
  	budget.load_elements(budget_id, project_id, type_of_budget, database)

  	redirect_to :action => :get_budget_by_project
  end

  def administrate_budget
    project = CostCenter.find(params[:project_id])
    @valorization = project.valorizations
    @budget = project.budgets
    render :administrate_budget, layout: false
  end

  def administrate_invoices
    @valorization = Valorization.all

    @budget = Budget.all
    render :administrate_budget, layout: false
  end



  def edit    
    @budget = Budget.find(params[:id])  
    render :edit, layout: false
  end

  def update
    @budget = Budget.find(params[:id])  
    @budget.update_attributes(budget_parameters)
    @budget = Budget.all
    render :administrate_budget, layout: false
  end

  def resume    
    @budget = Budget.find(params[:id])
    render :resume, layout: false
  end

  def destroy_admin
    budget=Budget.find(params[:id])
    project_id = budget.cost_center_id

    budgets = Budget.where("cod_budget LIKE ? and cost_center_id = ?", budget.cod_budget + "%", project_id)
    budgets.each do |budget_item|
      #Inputbybudgetanditem.where(budget_id: budget_item.id).destroy_all

      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM inputbybudgetanditems where budget_id='#{budget_item.id}'")
      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM itembybudgets where budget_id='#{budget_item.id}'")
      ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM itembywbses where budget_id='#{budget_item.id}'")
    end
    
    budgets.destroy_all
    ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM budgets where cod_budget LIKE '#{budget.cod_budget}' and cost_center_id = '#{budget.cost_center_id}'")
    ActiveRecord::Base.connection.send(:delete_sql,"DELETE FROM items where budget_code LIKE '#{budget.cod_budget}' and cost_center_id = '#{budget.cost_center_id}'")

    #DESTROY
    #@budgets_goal = Budget.where("type_of_budget = ? AND project_id = ? ", '0', project_id)
    #@budgets_sale = Budget.where("type_of_budget = ? AND project_id = ? ", '1', project_id)
    @budget = Budget.all
    render :administrate_budget, layout: false
  end

  private
  def budget_parameters
    params.require(:budget).permit(:cod_budget, :description, :term, :cost_center_id, :level, :subbudget_code, :deleted, :type_of_budget, :utility, :general_expenses)
  end
end
