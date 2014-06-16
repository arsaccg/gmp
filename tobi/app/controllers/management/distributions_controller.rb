class Management::DistributionsController < ApplicationController
  
  
  def import_distributions
    @cost_center_id = params[:project_id]
    @distribution = Distribution.select(:code).where('cost_center_id = ?', @cost_center_id).first()
  end
  
  def do_import
    Distribution.import_data_from_excel(params[:file], params[:cost_center_id], params[:quantity])
    redirect_to :action => :import_distributions
  end
end
