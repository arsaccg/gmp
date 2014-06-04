class MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    render layout: false
  end

  def home
    if get_company_cost_center('company').present? && get_company_cost_center('cost_center').present?
      @company = Company.find(get_company_cost_center('company'))
      @cost_center_name = CostCenter.find(get_company_cost_center('cost_center')).name
      render :show_panel, layout: 'dashboard'
    else
      redirect_to :controller => "errors", :action => "error_500"
    end
  end

  def show_panel
    session[:company] = params[:id]
    session[:cost_center] = params[:cost_center]
    redirect_to :action => :home
  end
end
