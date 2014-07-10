class Production::PartOfEquipmentsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = get_company_cost_center('company')
    @cost_center = get_company_cost_center('cost_center')
    # Necessary!
    @worker = Worker.where("cost_center_id = ?", @cost_center)
    @fuel_articles = Article.where("code LIKE ?", '__32%').first # Esto va a cambiar
    @working_group = WorkingGroup.where("cost_center_id = ?", @cost_center).first
    @worker = Worker.first
    render layout: false
  end

  def show_part_of_equipments
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    keyword = params[:sSearch]
    array = Array.new
    cost_center = get_company_cost_center('cost_center')

    partofequipments = PartOfEquipment.get_part_of_equipments(cost_center, display_length, pager_number, keyword)
    partofequipments.each do |partofequipment|
      if partofequipment[7] == 0
        array << [
          partofequipment[1],
          partofequipment[2],
          partofequipment[4],
          partofequipment[3],
          partofequipment[5],
          partofequipment[6],
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/production/part_of_equipments/" + partofequipment[0].to_s + "','content',null,null,'GET')> Ver Información </a> " + "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/production/part_of_equipments/" + partofequipment[0].to_s + "/edit','content',null,null,'GET')> Editar </a> " + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/production/part_of_equipments/" + partofequipment[0].to_s + "','content','/production/part_of_equipments') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar la parte N°" + partofequipment[0].to_s + "?' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"
        ]
      else
        array << [
          partofequipment[1],
          partofequipment[2],
          partofequipment[4],
          partofequipment[3],
          partofequipment[5],
          partofequipment[6],
          "<a class='btn btn-success btn-xs' onclick=javascript:load_url_ajax('/production/part_of_equipments/" + partofequipment[0].to_s + "','content',null,null,'GET')> Ver Información </a>"
        ]
      end
    end
    render json: { :aaData => array }
  end

  def show
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @partofequipment = PartOfEquipment.find(params[:id])
    @partdetail = PartOfEquipmentDetail.where("part_of_equipment_id LIKE ? ", params[:id])
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @working_groups= WorkingGroup.all
    @subcontracts = SubcontractEquipment.all
    @type = Article.where("code LIKE ?", '__32%')
    @worker = Array.new
    @worker = Worker.where("cost_center_id = ?", cost_center)
    subcontract_id = @partofequipment.subcontract_equipment_id
    unit=''
    equip = SubcontractEquipmentDetail.where("subcontract_equipment_id LIKE ?", subcontract_id)

    @articles = Article.get_article_per_type('03', cost_center)

    equip.each do |eq|
      @articles.each do |ar|
        if ar[0]==eq.article_id
          @unit1 = ar[4]
          break
        end
      end
    end
    @unit = UnitOfMeasurement.find(@unit1).name rescue ''
    render layout: false
  end

  def display_fuel_articles
    if params[:element].blank?
      word = params[:q]
      article_hash = Array.new
      articles = PartOfEquipment.getOwnFuelArticles(word, get_company_cost_center('cost_center'))
      articles.each do |art|
        article_hash << { 'id' => art[0], 'name' => art[1] }
      end
      render json: {:articles => article_hash}
    else
      article_hash = Array.new
      articles = ActiveRecord::Base.connection.execute("SELECT id, name FROM articles WHERE id = #{params[:element]}")
      articles.each do |art|
        article_hash << { 'id' => art[0], 'name' => art[1] }
      end
      render json: {:articles => article_hash}
    end
  end

  def new
    @company = params[:company_id]
    cost_center = get_company_cost_center('cost_center')
    @working_groups = WorkingGroup.where("cost_center_id = ?", cost_center)
    @partofequipment = PartOfEquipment.new
    @subcon = SubcontractEquipment.where("cost_center_id = ?", cost_center)
    @sectors = Sector.where("code LIKE '__' AND cost_center_id = ?", cost_center)
    pw_id = 0
    PositionWorker.where("name LIKE '%operador%'").each do |pw|
      pw_id = pw.id
    end
    @worker = Worker.where("cost_center_id = ? AND position_worker_id LIKE ?", cost_center, pw_id)
    render layout: false
  end

  def create
    part = PartOfEquipment.new(part_of_equipment_parameters)
    part.cost_center_id = get_company_cost_center('cost_center')
    part.block = 0
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
    cost_center = get_company_cost_center('cost_center')
    @partofequipment = PartOfEquipment.find(params[:id])
    @id = @partofequipment.equipment_id
    @working_groups = WorkingGroup.where("cost_center_id = ?", cost_center)
    @subcon = SubcontractEquipment.where("cost_center_id = ?", cost_center)
    @type = Array.new
    @fuel_articles = Article.where("code LIKE ?", '__32%')
    @worker = Worker.where("cost_center_id = ?", cost_center)

    @partdetail = PartOfEquipmentDetail.where("part_of_equipment_id LIKE ? ", params[:id])
    @reg_n = Time.now.to_i
    @sectors = Sector.where("code LIKE '__'")
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @working_groups= WorkingGroup.all
    @action="edit"
    render layout: false
  end

  def update
    part = PartOfEquipment.find(params[:id])
    if part.update_attributes(part_of_equipment_parameters)
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

  def destroy_detail
    partequip = PartOfEquipmentDetail.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Subcontrato de Equipo."
    render :json => part
  end

  def get_equipment_form_subcontract
    equip = Array.new
    @equipment = Array.new
    @code = Array.new
    @sedid = Array.new
    unit=''
    equip = SubcontractEquipmentDetail.where("subcontract_equipment_id LIKE ?", params[:subcontract_id])
    
    cost_center = get_company_cost_center('cost_center')
    articles = Article.get_article_per_type('03', cost_center)

    equip.each do |eq|
      @code << eq.code
      @sedid << eq.id
      articles.each do |ar|
        if ar[0]==eq.article_id
          @equipment << ar
          unit = ar[4]
        end
      end
    end
    #puts @sedid.inspect
    #puts @equipment.inspect
    @unit = UnitOfMeasurement.find(unit).name
    render json: {:equipment => @equipment, :unit =>@unit, :code => @code, :sedid => @sedid}  
  end

  def get_unit
    unit = Article.find(params[:article]).unit_of_measurement_id
    @symbol = UnitOfMeasurement.find(unit).symbol
    render json: {:symbol =>@symbol}  
  end

  def add_more_register
    @reg_n = ((Time.now.to_f)*100).to_i
    @sectors = Sector.where("code LIKE '__'")

    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    @phases = @phases.sort! { |a,b| a.code <=> b.code }
    @working_groups = WorkingGroup.all
    render(partial: 'part_equipment_register', :layout => false)
  end

  private
  def part_of_equipment_parameters
    params.require(:part_of_equipment).permit(
      :code, 
      :block, 
      :subcontract_equipment_id, 
      :equipment_id, 
      :worker_id, 
      :initial_km, 
      :final_km, 
      :dif, 
      :subcategory_id, 
      :fuel_amount, 
      :h_stand_by, 
      :h_maintenance, 
      :date, 
      :total_hours, 
      part_of_equipment_details_attributes: [
        :id, 
        :part_of_equipment_id, 
        :working_group_id, 
        :phase_id, 
        :sector_id, 
        :effective_hours, 
        :fuel, 
        :unit, 
        :_destroy
      ]
    )
  end
end 