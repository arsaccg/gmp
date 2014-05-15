class Production::SubcontractEquipmentDetailsController < ApplicationController
  def index
    @company = params[:company_id]
    @partequi = SubcontractEquipmentDetail.all
    @subcontract = params[:subcontract]
    render layout: false
  end

  def show
    @partequi = SubcontractEquipmentDetail.find(params[:id])
    render layout: false
  end

  def new
    @partequi = SubcontractEquipmentDetail.new
    @subcontract = SubcontractEquipment.find(params[:subcontract])
    TypeOfArticle.where("name LIKE '%EQUIPOS%'").each do |arti|
      @article << arti.articles
    end
    @rental = RentalType.all
    @company = params[:company_id]
    render layout: false
  end

  def create
    partequi = SubcontractEquipmentDetail.new(partequi_parameters)
    if partequi.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id], subcontract: params[:subcontract]
    else
      partequi.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id], subcontract: params[:subcontract] 
    end
  end

  def edit
    @partequi = SubcontractEquipmentDetail.find(params[:id])
    @subcontract = params[:subcontract]
    TypeOfArticle.where("name LIKE '%EQUIPOS%'").each do |arti|
      @article << arti.articles
    end
    @rental = RentalType.all
    @company = params[:company_id]
    @action="edit"
    render layout: false
  end

  def update
    subcontract = SubcontractEquipmentDetail.find(params[:id])
    if subcontract.update_attributes(partequi_parameters)
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
    partequi = SubcontractEquipmentDetail.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => partequi
  end

  private
  def partequi_parameters
    params.require(:subcontract_equipment_details).permit()
  end
end
