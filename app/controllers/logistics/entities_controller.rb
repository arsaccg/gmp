class Logistics::EntitiesController < ApplicationController
  def index
    @type_entities = TypeEntity.all
    render layout: false
  end

  def show
  end

  def new
    @reg_n = Time.now.to_i
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
    @reg_ed = Time.now.to_i
    @entity = Entity.find(params[:id])
    a=Array.new()
    b=Array.new()
    @type_entities = TypeEntity.all
    @entity.type_entities.each do |te|
      a[i]=te.id
      i+=1
    end
    @type_entities.each do |ty|
      b[i]=ty.id
      i+=1
    end
    @ete = a & b
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
    params[:entity_per_type_entities_attributes]
    params.require(:entity).permit(:name, :surname, :dni, :ruc, entity_per_type_entities_attributes: [:id, :entity_id, :type_entity_id, :_destroy])
    #params.require(:entity).permit(:name, :surname, :dni, :ruc)
  end
end