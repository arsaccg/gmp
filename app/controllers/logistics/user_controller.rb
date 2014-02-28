class Logistics::UserController < ApplicationController
  before_filter :authenticate_user!
  def index
  	@user = current_user
  	render layout: false
  end

  def edit
  end

  def update

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
