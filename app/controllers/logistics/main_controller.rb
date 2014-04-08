class Logistics::MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    if params[:company] != nil
      @company = Company.find(params[:company])
      render :show_panel, layout: 'dashboard' 
    else
      @companies = Company.all
      render layout: false
    end

  end

  def show_panel
    @namecomp=Company.find(params[:id])
    redirect_to :action => :index, :company =>@namecomp 
  end
end
