class Management::DistributionsController < ApplicationController
    
  def import_distributions
    @cost_center_id = get_company_cost_center('cost_center')
    @budgets = Budget.select("id, description, cod_budget").where('cost_center_id = ? AND type_of_budget = 1', @cost_center_id)
    render layout: false
  end

  def show_form
  	@budget_id = params[:id]
  	@cost_center_id = get_company_cost_center('cost_center')
  	@distribution = Distribution.select(:code).where('cost_center_id = ? AND budget_id = ?', @cost_center_id, @budget_id).first()
  	render layout: false
  end
  
  def do_import
  	if !params[:file].nil?
      @budget = Budget.find(params[:budget_id])
      if @budget.distributions.first.nil?
        Distribution.import_data_from_excel(params[:file], params[:cost_center_id], params[:quantity], params[:budget_id])
      else
        @budget.distributions.each do |distro|
          Distribution.destroy(distro.id)
          distro.distribution_items.each do |distro_item|
            DistributionItem.destroy(distro_item.id)
          end
        end
        Distribution.import_data_from_excel(params[:file], params[:cost_center_id], params[:quantity], params[:budget_id])
      end
  	end
    redirect_to :action => :import_distributions
  end
end
