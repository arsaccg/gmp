class Management::ItembybudgetsController < ApplicationController
  before_filter :authenticate_user!
  
  def index
  	@itembybudgets = Itembybudget.all
  end

  def filter_by_budget 
    #@total_budget = Itembybudget.where(:budget_id => params[:budget_id]).sum()
    @budget_id = params[:budget_id]
  	@itembybudgets = Itembybudget.where(:budget_id=>@budget_id).order(:order)
  	render :index, :layout => false
  end

  def new
    @itembybudget = Itembybudget.new
    @cost_center_id = get_company_cost_center('cost_center')
    render :new, :layout => false
  end

  def create
    @itembybudget = Itembybudget.new(itembybudget_parameters)
    item = Item.find(@itembybudget.item_id)
    budget = Budget.where(cod_budget: @itembybudget.budget_code).first
    # budget = Budget.find(@itembybudget.budget_id)
    @itembybudget.item_code = item.item_code
    @itembybudget.budget_id = budget.id
    @itembybudget.subbudget_code = budget.subbudget_code
    @itembybudget.budget_code = budget.cod_budget[0, 6]

    p @itembybudget
    if @itembybudget.save
      flash[:notice] = "Se ha creado correctamente nuevapartida."
    end
    render :new, layout: false
  end

  def show
  end

  def edit
    @itembybudget = Itembybudget.find(params[:id])
    budget = Budget.find(@itembybudget.budget_id)
    @cod_budget = budget.cod_budget[0..6]

    @items = Item.where("item_code LIKE '____________'").group(:item_code).order(:item_code) + Item.where("id = ?", @itembybudget.item_id) #167858
    #@item = Item.find(@itembybudget.item_id)
    
    #@item_id = @item.description == "REGISTRO RESTRINGIDO" ? Item.where(description: "REGISTRO RESTRINGIDO", cost_center_id: get_company_cost_center('cost_center')).first.id : @item.id
    #p "@item_id+~~~~~~~~~~~~~~~~~~~~+"
    #p @item_id
    render :edit, layout: false
  end

  def update
    @itembybudget = Itembybudget.find(params[:id])  
    @itembybudget.update_attributes(itembybudget_parameters)
    #render :administrate_budget, layout: false
    redirect_to :controller=>'budgets', :action => 'get_budget_by_project'
  end

  private
  def itembybudget_parameters
    params.require(:itembybudget).permit(:budget_id, :budget_code, :item_id, :subbudgetdetail, :order, :measured)
  end
end
