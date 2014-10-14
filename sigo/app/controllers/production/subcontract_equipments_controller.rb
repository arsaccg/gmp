class Production::SubcontractEquipmentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]  
  def index
    @supplier = TypeEntity.find_by_name('Proveedores').entities.first
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @subcontracts = SubcontractEquipment.where("cost_center_id = ?", cost_center)
    render layout: false
  end

  def show
    @company = params[:company_id]
    @subcontractEq = SubcontractEquipment.find(params[:id])
    render layout: false
  end

  def new
    @company = params[:company_id]
    @subcontractEquipment = SubcontractEquipment.new
    @suppliers = TypeEntity.find_by_preffix('P').entities
    @igv = FinancialVariable.find_by_name("IGV").value
    @company = params[:company_id]
    render layout: false
  end

  def create
    subcontract = SubcontractEquipment.new(subcontracts_parameters)
    subcontract.cost_center_id = get_company_cost_center('cost_center')
    if subcontract.save
      flash[:notice] = "Se ha creado correctamente el Subcontrato de Equipos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @company = params[:company_id]
    @subcontractEquipment = SubcontractEquipment.find(params[:id])
    @suppliers = TypeEntity.find_by_name('Proveedores').entities
    @company = params[:company_id]
    @igv = FinancialVariable.find_by_name("IGV").value
    @action="edit"
    @reg_n= Time.now.to_i
    render layout: false
  end

  def update
    subcontract = SubcontractEquipment.find(params[:id])
    subcontract.update_attributes(subcontracts_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, company_id: params[:company_id]
  rescue ActiveRecord::StaleObjectError
    subcontract.reload
    flash[:error] = "Alguien más ha modificado los datos en este instante. Intente Nuevamente."
    redirect_to :action => :index, company_id: params[:company_id] 
  end

  def destroy
    subcontract = SubcontractEquipment.find(params[:id])
    subcontract.subcontract_equipment_details.each do |part|
      partequi = SubcontractEquipmentDetail.destroy(part.id)
    end
    subcontract = SubcontractEquipment.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Subcontrato de Equipo."
    render :json => subcontract
  end

  def add_more_advance
    @advance = params[:advance]
    @date = params[:date]
    @reg_n = (Time.now.to_f*1000).to_i
    render(partial: 'subcontract_equipment_advance_items', :layout => false)
  end

  def get_report
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @poe =ActiveRecord::Base.connection.execute("
      SELECT a.code, CONCAT( a.name,  ' ',  'MARCA ', sed.brand,  ' ',  'MODELO ', sed.model,  ' ', sed.series ) , u.name, sed.code, e.name, sed.date_in, sed.price_no_igv, rt.name
      FROM articles_from_cost_center_"+@cc.id.to_s+" a, unit_of_measurements u, entities e, subcontract_equipment_details sed, subcontract_equipments se, rental_types rt
      WHERE se.cost_center_id = "+@cc.id.to_s+"
      AND sed.article_id = a.id
      AND a.unit_of_measurement_id = u.id
      AND se.entity_id = e.id
      AND sed.subcontract_equipment_id = se.id
      AND sed.rental_type_id = rt.id
      ORDER BY a.code
    ")
    @todo = Array.new
    @abuelo = Array.new
    @padre = Array.new
    @hijo = Array.new
    @poe.each do |poe|
      @code = poe[0].to_s
      if !@abuelo.include?(@code[2,2])
        @abuelo << @code[2,2]
        @todo << [@code[2,2],nil,nil,nil,nil,nil,nil,nil]
      end
      if !@padre.include?(@code[2,4])
        @padre << @code[2,4]
        @todo << [@code[2,4],nil,nil,nil,nil,nil,nil,nil]
      end
      if !@hijo.include?(@code[2,6])
        @hijo << @code[2,6]
        @todo << [@code[2,6],nil,nil,nil,nil,nil,nil,nil]
      end
      @todo << poe
    end
    puts @todo
    
    render :pdf => "reporte_listado_de_equipos-#{Time.now.strftime('%d-%m-%Y')}", 
           :template => 'production/subcontract_equipments/report_pdf.pdf.haml',
           :orientation => 'Landscape',
           :page_size => 'A4'
  end

  private
  def subcontracts_parameters
    params.require(:subcontract_equipment).permit(:entity_id, :lock_version, :valorization, :terms_of_payment, :initial_amortization_number, :initial_amortization_percent, :igv, :guarantee_fund,:contract_description, :detraction,
      subcontract_equipment_advances_attributes: [
        :id,
         :lock_version,
        :subcontract_equipment_id,
        :date_of_issue,
        :advance,
        :_destroy
      ])
  end
end



#  def add_more_article
#    @type = params[:type]
#    @reg_n = Time.now.to_i
#    @amount = params[:amount]
#    data_article_unit = params[:article_id].split('-')
#    @article = Article.find(data_article_unit[0])
#    @id_article = @article.id
#    @name_article = @article.name
#    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).name
#    render(partial: 'subcontract_items', :layout => false)
#  end