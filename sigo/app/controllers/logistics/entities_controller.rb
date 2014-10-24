class Logistics::EntitiesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  skip_before_filter  :verify_authenticity_token
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

  def show_entities
    display_length = params[:iDisplayLength]
    type_ent = params[:type_ent]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    comp = get_company_cost_center('company')
    array = Entity.get_entities(type_ent, comp, display_length, pager_number, keyword)
    render json: { :aaData => array }
  end

  def accounts
    @money = Money.all
    @bank = Bank.all
    @ent = Entity.find(params[:entity])
    @reg = ((Time.now.to_f)*100).to_i
    render layout: false
  end

  def add_account
    @bank = Bank.find(params[:bank])
    @money = Money.find(params[:money])
    @type = params[:type]
    @number = params[:number]
    @detraction = params[:detraction]
    @cci = params[:cci]
    @reg = ((Time.now.to_f)*100).to_i
    @ent = params[:ent]
    render(partial: 'account_detail', :layout => false)
  end  

  def update_bank_account
    entity = Entity.find(params[:id])
    entity.cost_center_id = get_company_cost_center('cost_center')
    if entity.update_attributes(entity_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      entity.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @entity = entity
      render :accounts, layout: false
    end    
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
    puts params[:button_id].inspect
    flash[:error] = nil
    entity = Entity.new(entity_parameters)
    entity.cost_center_id = get_company_cost_center('cost_center')
    if entity.save
      flash[:notice] = "Se ha creado correctamente la entidad."
      if params[:button_id]=='trabajadores'
        redirect_to url_for(:controller => "production/workers", :action => :new, :company_id => @company_id, :dni => entity.dni)
      else
        redirect_to :action => :index, company_id: params[:company_id]
      end
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
    worker = Worker.where('entity_id = ?',params[:id])
    worker.each do |del|
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
    params.require(:entity).permit(:name, :second_name, :date_of_birth,:paternal_surname, :maternal_surname, :dni, :ruc, :gender, :city, :province, :department, :alienslicense, {:type_entity_ids => []}, :address, entity_banks_attributes: [
      :id,
      :bank_id,
      :money_id,
      :entity_id,
      :account_type,
      :account_number,
      :account_detraction,
      :cci,
      :_destroy
      ])
  end

end