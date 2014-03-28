class Logistics::EntitiesController < ApplicationController
  def index
    @type_entities = TypeEntity.all
    render layout: false
  end

  def show
  end

  def new
    @type_entities = TypeEntity.all
    @entity = Entity.new
    render layout: false
  end

  def create
    entity = Entity.new(entity_parameters)
    if entity.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @entity = Entity.find(params[:id])
    @type_entities = TypeEntity.all
    @action = 'edit'
    render layout: false
  end

  def update
    entity = Entity.find(params[:id])
    entity.update_attributes(entity_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
    @entity = Entity.destroy(params[:id])
    render :json => @entity
  end

  private
  def entity_parameters
    params.require(:entity).permit(:name, :surname, :dni, :ruc, entity_per_type_entities_attributes: [:id, :entity_id, {:type_entity_id => []}])
    #params.require(:entity).permit(:name, :surname, :dni, :ruc)
  end
end
