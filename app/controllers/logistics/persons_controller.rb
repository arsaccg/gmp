class Logistics::PersonsController < ApplicationController

  def index
    @persons = User.all
    render layout: false
  end

  def new
    @user = User.new
    render layout: false
  end

  def create
    @user = User.new(user_params)
    @user.roles = [params[:role]]
    if @user.save
      flash[:notice] = "Se ha creado correctamente al usuario #{@user.first_name + ' ' + @user.last_name}."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def show
  	@person = current_user
  	render layout: false
  end

  def update
    @person = User.find(params[:id])
    @person.update_attributes(user_params)
    flash[:notice] = "Se ha actualizado correctamente al usuario #{@person.first_name + ' ' + @person.last_name}."
    redirect_to :action => 'show'
  end

  private
    def user_params
    	params.require(:user).permit(:first_name, :last_name, :surname, :email, :date_of_birth, :avatar, :password)
    end
end
