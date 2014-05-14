class Production::SubcontractEquipmentsController < ApplicationController
  def index
    @company = params[:company_id]
    @type = params[:type]
    if @type == 'subcontract'
      @subcontracts = Subcontract.where("type LIKE 'subcontract'")
    elsif @type == 'equipment'
      @subcontracts = Subcontract.where("type LIKE 'equipment'")
    end
    render layout: false
  end

  def show
    @subcontractEq = SubcontractEquipment.find(params[:id])
    render layout: false
  end

  def new
    @subcontractEq = SubcontractEquipment.new
    TypeEntity.where("name LIKE '%Proveedores%'").each do |supply|
      @suppliers = supply.entities
    end
    @company = params[:company_id]
    @type = params[:type]
    if @type == 'subcontract'
      @articles = TypeOfArticle.find(4).articles
    elsif @type == 'equipment'
      @articles = TypeOfArticle.find(3).articles
    end
    render layout: false
  end

  def create
    subcontract = SubcontractEquipment.new(subcontracts_parameters)
    if subcontract.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id], type: params[:subcontract]['type']
    else
      subcontract.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id], type: params[:subcontract]['type']
    end
  end

  def edit
    @subcontract = SubcontractEquipment.find(params[:id])
    TypeEntity.where("name LIKE '%Proveedores%'").each do |supply|
      @suppliers = supply.entities
    end
    @company = params[:company_id]
    @type = params[:type]
    if @type == 'subcontract'
      @articles = TypeOfArticle.find(4).articles
    elsif @type == 'equipment'
      @articles = TypeOfArticle.find(3).articles
    end
    render layout: false
  end

  def update
    subcontract = SubcontractEquipment.find(params[:id])
    if subcontract.update_attributes(subcontracts_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id], type: params[:subcontract]['type']
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
    subcontract = SubcontractEquipment.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => subcontract
  end

  private
  def subcontracts_parameters
    params.require(:subcontractEquipment).permit(:entity_id, :valorization, :terms_of_payment, :initial_amortization_number, :initial_amortization_percent, :guarantee_fund, :detraction, :contract_amount, :type, subcontract_details_attributes: [:id, :subcontract_id, :article_id, :amount, :unit_price, :partial, :description, :_destroy])
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