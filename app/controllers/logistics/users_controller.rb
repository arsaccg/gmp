class Logistics::UserController < ApplicationController
  before_filter :authenticate_user!
  def index
  	@user = current_user
    if params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def edit
  end

  def update
    @user = User.find(params[:id])
    @user.update_attributes(user_params)
    redirect_to :action => 'index', :task => 'edited'
  end

  def show
  	@user = current_user
  	render layout: false
  end

  private
    def user_params
    	params.require(:user).permit(:first_name, :last_name, :surname, :email, :date_of_birth, :avatar)
    end
end
