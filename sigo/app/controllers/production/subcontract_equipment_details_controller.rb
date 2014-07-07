class Production::SubcontractEquipmentDetailsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @company = params[:company_id]
    @subcontract = params[:subcontract]
    @partequi = SubcontractEquipmentDetail.where("subcontract_equipment_id= ?", @subcontract)
    @cost_center_id = get_company_cost_center('cost_center')
    #@article = TypeOfArticle.find_by_code("03").articles
    render layout: false
  end

  def display_articles
    name = get_company_cost_center('cost_center')
    if params[:element].blank?
      word = params[:q]
      article_hash = Array.new
      articles = SubcontractEquipmentDetail.getOwnArticles(word, name)
      articles.each do |art|
        article_hash << {'id' => art[0], 'name' => art[3] + ' - ' + art[1] + ' - ' + art[2]}
      end
      render json: {:articles => article_hash}
    else
      article_hash = Array.new
      articles = ActiveRecord::Base.connection.execute("SELECT id, name FROM articles_from_cost_center_" + name.to_s + " WHERE id = #{params[:element]}")
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
    @sum_contract_amount = 0
    partequi = SubcontractEquipmentDetail.new(partequi_parameters)
    if partequi.save

      subcontract_equipment = SubcontractEquipment.find(partequi.subcontract_equipment_id)
      subcontract_equipment.subcontract_equipment_details.each do |subcontract_detail|
        @sum_contract_amount += subcontract_detail.price_no_igv
      end

      if subcontract_equipment.update_attributes(:contract_amount => @sum_contract_amount)
        flash[:notice] = "Se ha creado correctamente el trabajador."
        redirect_to :action => :index, company_id: params[:company_id], subcontract: params[:subcontract]
      end
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
    @sum_contract_amount = 0
    subcontract = SubcontractEquipmentDetail.find(params[:id])
    if subcontract.update_attributes(partequi_parameters)

      subcontract_equipment = SubcontractEquipment.find(subcontract.subcontract_equipment_id)
      subcontract_equipment.subcontract_equipment_details.each do |subcontract_detail|
        @sum_contract_amount += subcontract_detail.price_no_igv
      end

      if subcontract_equipment.update_attributes(:contract_amount => @sum_contract_amount)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index, company_id: params[:company_id], subcontract: params[:subcontract]
      end
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
    @article = Article.find_article_in_specific(params[:article_id], get_company_cost_center('cost_center'))
    
    @article.each do |a|
      @code = a[3]
      @unit = a[4]
    end

    render json: {:code=>@code, :unit=>@unit}  
  end

  private
  def partequi_parameters
    params.require(:subcontract_equipment_detail).permit(:article_id, :description,:brand, :series, :model, :date_in, :year, :price_no_igv, :rental_type_id, :minimum_hours, :amount_hours, :contracted_amount, :subcontract_equipment_id, :code)
  end
end
