class Administration::ManagersController < ApplicationController
  before_filter :authorize_manager

  def new
  	@manager = Manager.new
	  render :new, :layout => 'dashboard'
  end

  def create
	  @manager = Manager.new(manager_parameters)
	  @manager.save

	  redirect_to :action => :index
  end

  def index
    render :index, :layout => 'dashboard'
  end

  private
  def manager_parameters
    params.require(:manager).permit(:email, :password, :dni, :kind)
  end

end
