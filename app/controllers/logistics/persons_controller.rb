class Logistics::PersonsController < ApplicationController
protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    if current_user.has_role? :director
      @persons = User.all
    else
      @persons = User.all.where('roles_mask NOT IN (1)')
    end
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

  # Función show solo para que vea su perfil.
  def show
  	@person = current_user
  	render layout: false
  end

  # Función para editar usuarios en el panel del director.
  def edit
    @action = 'edit'
    @user = User.find(params[:id])
    @all_roles = { 'issuer' => 'Emite las ordenes de suministro', 'approver' => 'Aprueba ordenes de Suministro', 'reviser' => 'Dar visto bueno a las ordenes de suministro', 'canceller' => 'Anular ordenes suministro' }
    @roles = @user.role_symbols
    puts @roles
    render layout: false
  end

  def update
    @person = User.find(params[:id])
    if params[:profile] != nil
      @person.roles = [params[:role]]
    else
      @person.roles = nil
    end
    @person.update_attributes(user_params)
    flash[:notice] = "Se ha actualizado correctamente al usuario #{@person.first_name + ' ' + @person.last_name}."
    if current_user.has_role? :director
      redirect_to :action => 'index'
    else
      redirect_to :action => 'show'
    end
  end

  def destroy
    user = User.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => user
  end

  def getCostCentersPerCompany
    if params[:costCenter] != nil
      cost_centers = params[:costCenter]
    end
    respond_to do |format|
      format.json { 
        data = ActiveRecord::Base.connection.execute("SELECT id,name FROM `cost_centers` WHERE `company_id` IN (#{cost_centers})")
        render :json => data
      }
    end
  end

  private
    def user_params
    	params.require(:user).permit(:first_name, :last_name, :surname, :email, :date_of_birth, :avatar, :password, {:company_ids => []}, {:cost_center_ids => []})
    end
end
