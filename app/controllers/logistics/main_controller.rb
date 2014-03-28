class Logistics::MainController < ApplicationController
  before_filter :authenticate_user!
  def index
    #render :all_companies, layout: false
    render layout: 'dashboard'
  end

  def index_app
    @companies=Company.all
  	render :all_companies, layout: false
  end
end
