class Logistics::TypeEntitiesController < ApplicationController
  def index
    @type_entities = TypeEntity.all
    render layout: false
  end

  def show
  end

  def new
    @type_entity = TypeEntity.new
    render layout: false
  end

  def create
    type_entity = TypeEntity.new(type_entity_parameters)
    if type_entity.save
      flash[:notice] = "Se ha creado correctamente el nuevo tipo de entidad."
      redirect_to :action => :index
    else
      type_entity.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @type_entity = type_entity
      render :new, layout: false
    end
  end

  def edit
    @type_entity = TypeEntity.find(params[:id])
    render layout: false
  end

  def update
    type_entity = TypeEntity.find(params[:id])
    if type_entity.update_attributes(type_entity_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      type_entity.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @type_entity = type_entity
      render :edit, layout: false
    end
  end

  def destroy
    @type_entity = TypeEntity.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => @type_entity
  end

  private
  def type_entity_parameters
    params.require(:type_entity).permit(:name, :preffix)
  end
end
