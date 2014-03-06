class Logistics::PersonsController < ApplicationController
  def index
  end

  def show
  	@person = current_user
  	render layout: false
  end

  def update
    @person = User.find(params[:id])
    @person.update_attributes(user_params)
    redirect_to :action => 'show'
  end

  private
    def user_params
    	params.require(:user).permit(:first_name, :last_name, :surname, :email, :date_of_birth, :avatar)
    end
end
