class Production::SubcontractEquipmentDetailsController < ApplicationController
  def index
    @company = params[:company_id]
    @subcontract = params[:subcontract]
    @partequi = SubcontractEquipmentDetail.where("subcontract_equipment_id= ?", @subcontract)
    @article= Array.new
    @article = TypeOfArticle.find_by_code("03").articles
    render layout: false
  end

  def display_articles
    if params[:element].blank?
      word = params[:q]
      article_hash = Array.new
      articles = ActiveRecord::Base.connection.execute("SELECT id, name FROM articles WHERE code LIKE '03%' AND name LIKE '%#{word}%'")
      articles.each do |art|
        article_hash << {'id' => art[0], 'name' => art[1]}
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

  def show
    @partequi = SubcontractEquipmentDetail.find(params[:id])
    render layout: false
  end

  def new
    @company = params[:company_id]
    @subcontract = params[:subcontract]
    @partequi = SubcontractEquipmentDetail.new
    @article = TypeOfArticle.find_by_code("03").articles
    @rental = RentalType.all
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
    @company = params[:company_id]
    @subcontract = params[:subcontract]
    @partequi = SubcontractEquipmentDetail.find(params[:id])
    @rental = RentalType.all
    @action="edit"
    render layout: false
  end

  def update
    subcontract = SubcontractEquipmentDetail.find(params[:id])
    if subcontract.update_attributes(partequi_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id], subcontract: params[:subcontract]
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

  def get_component_from_article
    @article = Article.find(params[:article_id])
    @code = @article.code
    unit = UnitOfMeasurement.find(@article.unit_of_measurement_id)
    @unit = unit.name
    render json: {:code=>@code, :unit=>@unit}  
  end

  private
  def partequi_parameters
    params.require(:subcontract_equipment_detail).permit(:article_id, :description,:brand, :series, :model, :date_in, :year, :price_no_igv, :rental_type_id, :minimum_hours, :amount_hours, :contracted_amount, :subcontract_equipment_id)
  end
end
