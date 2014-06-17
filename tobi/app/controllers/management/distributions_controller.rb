class Management::DistributionsController < ApplicationController
    
  def import_distributions
    @cost_center_id = params[:project_id]
    @budgets = Budget.select(:id, :description, :cod_budget).where('cost_center_id = ? AND type_of_budget = 1', @cost_center_id)
    render layout: false
  end

  def show_form
  	@budget_id = params[:id]
  	@cost_center_id = params[:project_id]
  	@distribution = Distribution.select(:code).where('cost_center_id = ? AND budget_id = ?', @cost_center_id, @budget_id).first()
  	render layout: false
  end
  
  def do_import
  	if !params[:file].nil?
      Distribution.import_data_from_excel(params[:file], params[:cost_center_id], params[:quantity], params[:budget_id])
  	end
    redirect_to :action => :import_distributions
  end
end
