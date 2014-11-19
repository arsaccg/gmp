class Management::ValorizationsController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update, :newvalorization, :changevalorization, :finalize, :show_data, :change_data_ge, :change_data_u, :change_data_r, :change_data_rnd, :change_data_rnm, :change_data_da, :change_data_aom, :report ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
    
  def index
    @redir = params[:redir]
    p @redir
    @budgets=Budget.where(:cost_center_id => get_company_cost_center('cost_center'))
    render :index, :layout => false
  end
  
  def newvalorization
    @itembybudgets = Itembybudget.all
    @budget = Budget.find(params[:id])
    @valorization = Valorization.new
    @valorization.budget_id = @budget.id 

    all_budgets = Budget.where(:cost_center_id => @budget.cost_center_id)
    @num_val = 1
    all_budgets.each do |i|
      @num_val = @num_val + Valorization.where(budget_id: i.id).count
    end

    render :newvalorization, layout: false
  end

  def edit
     @valorization = Valorization.find(params[:id])
     render :edit, layout: false
  end

  def update
      @valorization = Valorization.find(params[:id])
      @valorization.update_attributes(valorization_parameters)
      cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

      redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def destroy
    @redir = params[:redir]
    @valorization = Valorization.find(params[:id])
    @valorization.destroy

    # project = CostCenter.find(get_company_cost_center('cost_center'))
    # @valorization = project.valorizations
    # @budget = project.budgets
    #render "management/budgets/administrate_budget", layout: false
    @budgets=Budget.where(:cost_center_id => get_company_cost_center('cost_center'))
    render action: :index, redir: 1, layout: false
  end


  def changevalorization
  	@itembybudgets = Itembybudget.all
    @valorization = Valorization.find(params[:id])
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id) rescue 0
 

    str_query = "SELECT  itembybudgets.id, 
                  IF(itembybudgets.subbudgetdetail = '', itembybudgets.title, itembybudgets.subbudgetdetail),  
                  itembybudgets.order,  
                  IFNULL(get_prev_valorizations('" + @valorization.valorization_date.to_s.gsub('UTC', '') + "', itembybudgets.id),0), 
                  measured,
                  IFNULL(valorizationitems.actual_measured, 0) as valorization_actual
                  FROM itembybudgets LEFT JOIN valorizationitems
                  ON valorizationitems.itembybudget_id=itembybudgets.id AND
                  valorizationitems.valorization_id = '" + @valorization.id.to_s + "'
                  WHERE itembybudgets.budget_id = '" + @budget.id.to_s + "'
                ORDER BY itembybudgets.`order`;"
    p str_query

    @results = ActiveRecord::Base.connection.execute(str_query) 
    

    @valorization.semicomplete

    render :changevalorization, layout: false
  end

  def create
    valorization = Valorization.new(valorization_parameters)
    valorization.month = "Valorizacion : " + valorization.valorization_date.strftime("%B %Y")

    valorization.save

    cost_center_id = Budget.find(valorization.budget_id).cost_center_id

    redirect_to :controller => "management/budgets", project_id: cost_center_id, :action => :administrate_budget
  end

  def finalize
    @valorization = Valorization.find(params[:id])
    @valorization.complete!

    cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

    redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def show_data
    @valorization = Valorization.find(params[:id])
    
    @month = @valorization.valorization_date.to_date.strftime("%-m").to_i
    @year = @valorization.valorization_date.to_date.strftime("%Y").to_i 

    render :show_data, layout: false
  end

  ###~###
  def change_data_ge
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.general_expenses = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_u
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.utility = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_r
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.readjustment = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_rnd
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.no_direct_r = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_rnm
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.no_materials_r = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_da
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.direct_advance = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_aom
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.advance_of_materials = new_value
    @valorization.save
    render :show_data, layout: false
  end
  ###~###

  def report
    @valorization = Valorization.find(params[:id])
    @itembybudgets = Itembybudget.where('CHAR_LENGTH(`order`) > 3 AND budget_id = ?', @valorization.budget_id)
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id)

    @project = CostCenter.find(@budget.cost_center_id)

    @itembybudgets_main = Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', @valorization.budget_id)
    
    @month = @valorization.valorization_date.to_date.strftime("%-m").to_i
    @year = @valorization.valorization_date.to_date.strftime("%Y").to_i 

    render :report, layout: false
  end

  private
  def valorization_parameters
    params.require(:valorization).permit(:month, :name, :status, :budget_id, :valorization_date)
  end

end
