class Logistics::EntitiesController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @type_entities = TypeEntity.all
    @i=0
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
    @company_id = params[:company_id]
    @costCenter = Company.find(params[:company_id]).cost_centers
    render layout: false
  end

  def create
    flash[:error] = nil
    entity = Entity.new(entity_parameters)
    if entity.save
      flash[:notice] = "Se ha creado correctamente la nueva orden de suministro."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      entity.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @entity = entity
      render :new, layout: false 
      #flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      #redirect_to :action => :index
    end
  end

  def edit
    @company_id = get_company_cost_center('company')
    @reg_ed = Time.now.to_i
    @entity = Entity.find(params[:id])
    @type = params[:type]
    @costCenter = Company.find(@company_id).cost_centers
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
    if entity.update_attributes(entity_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      entity.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @entity = entity
      render :edit, layout: false
    end
  end

  def destroy
    entity = Entity.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente la entidad."
    render :json => entity
  end

  private
  def entity_parameters
    params.require(:entity).permit(:name, :second_name, :date_of_birth,:paternal_surname, :maternal_surname, :dni, :ruc, {:type_entity_ids => []}, :address)
  end
end