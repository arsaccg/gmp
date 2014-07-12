class Logistics::EntitiesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
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
    entity.cost_center_id = get_company_cost_center('cost_center')
    if entity.save
      flash[:notice] = "Se ha creado correctamente la entidad."
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
    entity.cost_center_id = get_company_cost_center('cost_center')
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
    delete = 0
    subcontract = Subcontract.where('entity_id = ?',params[:id])
    subcontract.each do |del|
      delete +=1
    end
    subcontractequip = SubcontractEquipment.where('entity_id = ?',params[:id])
    subcontractequip.each do |del|
      delete +=1
    end
    stockinput = StockInput.where('supplier_id = ?',params[:id])
    stockinput.each do |del|
      delete +=1
    end
    if delete > 0
      flash[:error] = "No se puede eliminar la entidad."
      entity = 'true'
    else
      flash[:notice] = "Se ha eliminado correctamente la entidad."
      entity = Entity.destroy(params[:id])
    end
    render :json => entity
  end

  private
  def entity_parameters
    params.require(:entity).permit(:name, :second_name, :date_of_birth,:paternal_surname, :maternal_surname, :dni, :ruc, :gender, {:type_entity_ids => []}, :address)
  end
end