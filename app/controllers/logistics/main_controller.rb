class Logistics::MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    if params[:flag]
      if params[:company] != nil
        @company = params[:company]
      end
      render :show_panel, layout: 'dashboard' 
    else
      @companies = Company.all
      render layout: false
    end

  end

  def show_panel
    @namecomp=Company.find(params[:id])
    redirect_to :action => :index, :flag => true, :company =>@namecomp 
  end
end
