class Management::EquivalenceOfItemsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @equiarray = Array.new
    equivalence = EquivalenceOfItem.uniq.pluck(:sale_item_by_budget_id)
    equivalence.each do |equi|
      eq = EquivalenceOfItem.where("sale_item_by_budget_id = ?",equi).first
      @equiarray << [eq.sale_item_by_budget_id,eq.target_item_by_budget_id,eq.percentage]
    end
    render layout: false
  end

  def link_budget_front
    budgets_goal = Budget.where("type_of_budget = ? AND cost_center_id = ?", '0', get_company_cost_center('cost_center')).first rescue nil
    @message_error = ''
    if !budgets_goal.nil?
      @goalitembybudgets = Itembybudget.where("budget_id = ? AND measured != ''  AND percentage<100",budgets_goal.id).order(:order)
      budgets_sale = Budget.where("type_of_budget = ? AND cost_center_id = ?", '1', get_company_cost_center('cost_center')).first
      @saleitembybudgets = Itembybudget.where("budget_id = ? AND measured != ''  AND percentage<100",budgets_sale.id).order(:order)
    else
      @message_error = "Este centro de costo no tiene ningún Presupuesto Meta."
    end
    render(partial: 'link_budget_front', :layout => false)
  end

  def add_item
    @reg_n = ((Time.now.to_f)*100).to_i
    @saleitembybudget = Itembybudget.find(params[:item_id])
    render(partial: 'table_items', :layout => false)
  end

  def add_item2
    @reg_n = ((Time.now.to_f)*100).to_i
    @goalitembybudget = Itembybudget.find(params[:item_id])
    render(partial: 'table_items2', :layout => false)
  end

  def link_budget_method
    equivalence = EquivalenceOfItem.new
    equivalence.sale_item_by_budget_id = params[:target_id]
    equivalence.target_item_by_budget_id = params[:sale_id]
    equivalence.percentage = params[:percentage]
    equivalence.cost_center_id = get_company_cost_center('cost_center')
    equivalence.save
    saleitembybudget = Itembybudget.find(params[:target_id])
    saleitembybudget.percentage = saleitembybudget.percentage + params[:percentage].to_f
    saleitembybudget.save
    goalitembybudget = Itembybudget.find(params[:sale_id])
    goalitembybudget.percentage = 100
    goalitembybudget.save
    render :layout => false
  end

  def destroy
    equivalences = EquivalenceOfItem.where("sale_item_by_budget_id = ?",params[:id])
    equivalences.each do |eq|
      target_item_by_budget = Itembybudget.find(eq.target_item_by_budget_id)
      target_item_by_budget.percentage = 0
      target_item_by_budget.save
      sale_item_by_budget = Itembybudget.find(eq.sale_item_by_budget_id)
      sale_item_by_budget.percentage = 0
      sale_item_by_budget.save
      destroy = EquivalenceOfItem.destroy(eq.id)
    end
    flash[:notice] = "Se ha eliminado correctamente el banco seleccionado."
    render :json => equivalences
  end

end