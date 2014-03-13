class Logistics::CenterOfAttentionsController < ApplicationController
  before_filter :authenticate_user!, :only => [:update, :index, :new, :create, :edit]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @centerOfAttention = CenterOfAttention.all
    render layout: false
  end

  def new
    @centerOfAttention = CenterOfAttention.new
    render :new, layout: false
  end

  def create
    centerOfAttention = CenterOfAttention.new(center_of_attentions_parameters)
    if centerOfAttention.save
      flash[:notice] = "Se ha creado correctamente el centro de atención."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @centerOfAttention = CenterOfAttention.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    centerOfAttention = CenterOfAttention.find(params[:id])
    centerOfAttention.update_attributes(center_of_attentions_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
    centerOfAttention = CenterOfAttention.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => centerOfAttention
    #redirect_to :action => :index, :task => 'deleted'
  end

  private
  def center_of_attentions_parameters
    params.require(:center_of_attention).permit(:name, :abbreviation)
  end
end
