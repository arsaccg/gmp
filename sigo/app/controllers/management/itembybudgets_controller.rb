class Management::ItembybudgetsController < ApplicationController
  before_filter :authorize_manager
  
  def index
  	@itembybudgets = Itembybudget.all
  	
  end

  def filter_by_budget 
    #@total_budget = Itembybudget.where(:budget_id => params[:budget_id]).sum()
    @budget_id = params[:budget_id]
  	@itembybudgets = Itembybudget.where(:budget_id=>params[:budget_id])
  	render :index, :layout => false
    
  end

  def new
  end

  def show
  end

end
