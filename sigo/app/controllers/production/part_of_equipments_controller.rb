class Production::PartOfEquipmentsController < ApplicationController
  def index
    @company = params[:company_id]
    @partofequipment = PartOfEquipment.all
    render layout: false
  end

  def show
    @company = params[:company_id]
    @partofequipment = PartOfEquipment.find(params[:id])
    render layout: false
  end

  def new
    @company = params[:company_id]
    @working_groups = WorkingGroup.all
    @partofequipment = PartOfEquipment.new
    @subcon = SubcontractEquipment.all
    @type = Array.new
    Category.where("code LIKE ?",32).each do |cat|
      @type=cat.subcategories
    end
    @worker = Array.new
    CategoryOfWorker.where("name LIKE '%operador%'").each do |wo|
      @worker= wo.workers
    end
    render layout: false
  end

  def create
    part = PartOfEquipment.new(partOfEquipment_parameters)
    if part.save
      flash[:notice] = "Se ha creado correctamente el parte."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      part.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @company = params[:company_id]
    @working_groups = WorkingGroup.all
    @partofequipment = PartOfEquipment.find(params[:id])
    @subcon = SubcontractEquipment.all
    @type = Array.new
    Category.where("code LIKE ?",32).each do |cat|
      @type=cat.subcategories
    end
    @worker = Array.new
    CategoryOfWorker.where("name LIKE '%operador%'").each do |wo|
      @worker= wo.workers
    end
    @action="edit"
    render layout: false
  end

  def update
    part = PartOfEquipment.find(params[:id])
    if part.update_attributes(partOfEquipment_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      part.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @part = part
      render :edit, layout: false
    end
  end

  def destroy
    part = PartOfEquipment.find(params[:id])
    part.part_of_equipment_details.each do |parte|
      partequip = PartOfEquipmentDetail.destroy(parte.id)
    end
    part = PartOfEquipment.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Subcontrato de Equipo."
    render :json => part
  end

  def get_equipment_form_subcontract
    @equipment= Array.new
    SubcontractEquipment.where("id = ?", params[:subcontract_id]).each do |sce|
      @equipment = sce.subcontract_equipment_details
    end
    render json: {:equipment => @equipment}  
  end

  def add_more_register
    @reg_n = Time.now.to_i
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.where("code LIKE '__'")
    @working_groups= WorkingGroup.all
    render(partial: 'part_equipment_register', :layout => false)
  end

  private
  def partOfEquipment_parameters
    params.require(:part_of_equipment).permit(:code, :entity_id, :equipment, :worker_id, :hour_meter, :mileage, :dif, :sub_group_id, :fuel_amount, :h_stand_by, :h_maintenance, :date, :total_hours, 
      part_of_equipment_details_attributes: [:id, :part_of_equipment_id, :work_group_id, :sub_sector_id, :sub_phase_id, :efective_hours, :unitname, :_destroy])
  end
end 