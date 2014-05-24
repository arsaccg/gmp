class MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    render layout: false
  end

  def home
    if get_company_cost_center('company').present? && get_company_cost_center('cost_center').present?
      @company = Company.find(get_company_cost_center('company'))
      render :show_panel, layout: 'dashboard'
    else
      redirect_to :controller => "errors", :action => "error_500"
    end
  end

  def show_panel
    Rails.cache.write('company', params[:id])
    Rails.cache.write('cost_center', params[:cost_center])
    redirect_to :action => :home
  end
end
