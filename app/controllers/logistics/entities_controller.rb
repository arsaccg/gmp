class Logistics::EntitiesController < ApplicationController
  def index
    @type_entities = TypeEntity.all
    render layout: false
  end

  def show
    @entity = Entity.find(params[:id])
    render layout: false
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
      entity.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @reg_ed = Time.now.to_i
    @entity = Entity.find(params[:id])
    @all_entity_types = Array.new
    @own_entity_types = Array.new
    # Comenzando lógica
    @type_entities = TypeEntity.all

    @type_entities.each do |type_entity|
      @all_entity_types << type_entity
    end

    @entity.type_entities.each do |enty|
      @own_entity_types << enty
    end

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
    params.require(:entity).permit(:name, :surname, :dni, :ruc, {:type_entity_ids => []})
  end
end