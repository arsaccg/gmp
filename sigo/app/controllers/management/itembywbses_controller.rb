class Management::ItembywbsesController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]

  def index
  	
  end

  def new
  end

  def show
  end

  def get_wbsitem_assigned
    str_id = params[:itembybudget]
    @itembywbs = Itembywbs.where("itembybudget_id = ?", str_id)
    render :layout => false
  end

  def add_data_item

    @wbs = params[:wbscode]
    
    temp_wbs = Wbsitem.where(:codewbs => params[:wbscode].to_s).first
    budget = Budget.find(params[:budget_id])
    item = Item.where(:item_code => params[:item_code]).first
    order = (params[:order].to_s).gsub('a', '.')

    str_name  = (CGI.unescape(params[:subbudgetdetail])).to_s.gsub('_', '\'')

    new_item = Itembywbs.where("budget_id = ? AND itembybudget_id = ? AND wbscode = ? AND order_budget = ?", params[:budget_id],  params[:id], params[:wbscode].to_s,  order).first


    item_by_budget = Itembybudget.find(params[:id])

    get_total_assigned = Itembywbs.where("itembybudget_id = ?", params[:id]).sum(:measured)
    
    if item_by_budget.measured.to_f > get_total_assigned.to_f

      if new_item == nil
        new_item=Itembywbs.new
        new_item.coditem = params[:item_code]
        new_item.wbscode = params[:wbscode]
        new_item.wbsitem_id = temp_wbs.id
        new_item.budget_id = params[:budget_id]
        new_item.budget_code=budget.cod_budget
        new_item.subbudgetdetail = str_name
        new_item.itembybudget_id = params[:id]
        new_item.order_budget = order
        new_item.item_id = item.id
      end

      new_item.price=(params[:price].to_s.gsub('a', '.')).to_f
      new_item.measured=(params[:measured].to_s.gsub('a', '.')).to_f
    
      new_item.save
    end 

    @wbsitems = Wbsitem.where("codewbs LIKE ?", get_company_cost_center('cost_center').to_s + "%").order(:codewbs)
    @budgets = Budget.where(cost_center_id: get_company_cost_center('cost_center'), id: params[:budget_id])
    @wbsitems_arr = Array.new
    @budgets.each do |budget|
      temp_wbsitems = budget.itembywbses
      temp_wbsitems.each do |item| 
          @wbsitems_arr << item
      end
    end

    render layout: false

  end

  def save_data
    new_item = nil

  	params[:itemform].each do |k, v|
      new_item = Itembywbs.find(v['itembywbs_id'])
      new_item.price=v['price'].to_s
      new_item.measured=v['measured'].to_s
  		new_item.save
  	end

    @items = Itembybudget.where(:budget_id => new_item.budget_id)
    render   "management/wbsitems/get_items_by_budget", layout: false

  end

  def destroy
    itembybudget = Itembywbs.find(params[:id])

    itembybudget.destroy

    @wbs = params[:wbscode]
    
    @wbsitems = Wbsitem.where("codewbs LIKE ?", get_company_cost_center('cost_center').to_s + "%").order(:codewbs)
    @budgets = Budget.where(:cost_center_id => get_company_cost_center('cost_center'))
    @wbsitems_arr = Array.new
    @budgets.each do |budget|
      temp_wbsitems = budget.itembywbses
      temp_wbsitems.each do |item| 
        @wbsitems_arr << item
      end
    end

    render 'add_data_item', layout: false
  end
end
