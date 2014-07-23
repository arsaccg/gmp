class Management::ValorizationsController < ApplicationController
  before_filter :authorize_manager
  
  def index
    @budgets=Budget.where(:cost_center_id => params[:project_id])
    render :index, :layout => false
  end
  
  def newvalorization
    @itembybudgets = Itembybudget.all
    @budget = Budget.find(params[:id])
    @valorization = Valorization.new
    @valorization.budget_id = @budget.id 

    render :newvalorization, layout: false
  end

  def edit
     @valorization = Valorization.find(params[:id])
     render :edit, layout: false
  end

  def update
      @valorization = Valorization.find(params[:id])
      @valorization.update_attributes(params[:valorization])
      cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

      redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def destroy
    @valorization = Valorization.find(params[:id])
    cost_center_id = Budget.find(@valorization.budget_id).cost_center_id
    @valorization.destroy
    redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end


  def changevalorization
  	@itembybudgets = Itembybudget.all
    @valorization = Valorization.find(params[:id])
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id) rescue 0
 

    str_query = "SELECT  itembybudgets.id, 
                  IF(itembybudgets.title = 'REGISTRO RESTRINGIDO', itembybudgets.subbudgetdetail, itembybudgets.title),  
                  itembybudgets.order,  
                  IFNULL(get_prev_valorizations('" + @valorization.valorization_date.to_s.gsub('UTC', '') + "', itembybudgets.id),0), 
                  measured,
                  IFNULL(valorizationitems.actual_measured, 0) as valorization_actual
                  FROM itembybudgets LEFT JOIN valorizationitems
                  ON valorizationitems.itembybudget_id=itembybudgets.id AND
                  valorizationitems.valorization_id = '" + @valorization.id.to_s + "'
                  WHERE itembybudgets.budget_id = '" + @budget.id.to_s + "'
                ORDER BY itembybudgets.`order`;"

    connection = ActiveRecord::Base.connection
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

  def edit
    #val_item = Valorizationitem
    redirect_to :controller => "management/budget", :action => :administrate_budget
  end

  def finalize
    @valorization = Valorization.find(params[:id])
    @valorization.complete!

    cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

    redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def show_data
    @valorization = Valorization.find(params[:id])
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
    @itembybudgets = Itembybudget.all
    @valorization = Valorization.find(params[:id])
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id)

    @project = CostCenter.find(@budget.cost_center_id)

    @itembybudgets_main = Itembybudget.select('id, `title`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3')
    #SELECT `order`,CHAR_LENGTH(`order`) WHERE CHAR_LENGTH(`order`) < 3
    render :report, layout: false
  end

  private
  def valorization_parameters
    params.require(:valorization).permit(:month, :name, :status, :budget_id, :valorization_date)
  end

end
