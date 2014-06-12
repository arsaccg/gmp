class Management::DistributionsController < ApplicationController
  
  
  def import_distributions
    @cost_center_id = params[:project_id]
  end
  
  def do_import
    Distribution.import_data_from_excel(params[:file], params[:cost_center_id], params[:quantity])
  end
end
