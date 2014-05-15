class Production::SubcontractEquipmentsController < ApplicationController
  def index
    @company = params[:company_id]
    @subcontracts = SubcontractEquipment.all
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
    TypeEntity.where("name LIKE '%Proveedores%'").each do |supply|
      @suppliers = supply.entities
    end
    @company = params[:company_id]
    render layout: false
  end

  def create
    subcontract = SubcontractEquipment.new(subcontracts_parameters)
    if subcontract.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
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
    TypeEntity.where("name LIKE '%Proveedores%'").each do |supply|
      @suppliers = supply.entities
    end
    @company = params[:company_id]
    @action="edit"
    render layout: false
  end

  def update
    subcontract = SubcontractEquipment.find(params[:id])
    if subcontract.update_attributes(subcontracts_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @subcontract = subcontract
      render :edit, layout: false
    end
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

  private
  def subcontracts_parameters
    params.require(:subcontract_equipment).permit(:entity_id, :valorization, :terms_of_payment, :initial_amortization_number, :initial_amortization_percent, :guarantee_fund, :detraction, :contract_amount)
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