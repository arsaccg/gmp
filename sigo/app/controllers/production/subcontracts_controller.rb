class Production::SubcontractsController < ApplicationController
  def index
    # General
    @supplier = TypeEntity.find_by_name('Proveedores').entities.first
    @article = TypeOfArticle.find_by_name('subcontratos').articles.first
    @company = params[:company_id]
    @subcontracts = Subcontract.all
    render layout: false
  end

  def show
    @subcontract = Subcontract.find(params[:id])
    render layout: false
  end

  def new
    @subcontract = Subcontract.new
    @suppliers = TypeEntity.find_by_name('Proveedores').entities
    @company = params[:company_id]
    @articles = TypeOfArticle.find_by_code('04').articles

    render layout: false
  end

  def create
    subcontract = Subcontract.new(subcontracts_parameters)
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

  def add_more_article
    @type = params[:type]
    @reg_n = Time.now.to_i
    @amount = params[:amount]
    data_article_unit = params[:article_id].split('-')
    @article = Article.find(data_article_unit[0])
    @id_article = @article.id
    @name_article = @article.name
    @unitOfMeasurement = UnitOfMeasurement.find(data_article_unit[1]).name
    render(partial: 'subcontract_items', :layout => false)
  end

  def edit
    @subcontract = Subcontract.find(params[:id])
    @suppliers = TypeEntity.find_by_name('Proveedores').entities
    @company = params[:company_id]
    @articles = TypeOfArticle.find_by_code('04').articles
    @reg_n = Time.now.to_i
    @action="edit"
    render layout: false
  end

  def update
    subcontract = Subcontract.find(params[:id])
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
    subcontract = Subcontract.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Grupo de Trabajo."
    render :json => subcontract
  end

  private
  def subcontracts_parameters
    params.require(:subcontract).permit(:entity_id, :valorization, :terms_of_payment, :initial_amortization_number, :initial_amortization_percent, :guarantee_fund, :detraction, :contract_amount, :igv, :type, subcontract_details_attributes: [:id, :subcontract_id, :article_id, :amount, :unit_price, :partial, :description, :_destroy])
  end
end
