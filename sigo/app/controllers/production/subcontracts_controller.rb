class Production::SubcontractsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
   # General
    @supplier = TypeEntity.find_by_name('Proveedores').entities.first
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @subcontracts = Subcontract.where("cost_center_id = ?", cost_center)
    render layout: false
  end
 
  def display_articles
    word = params[:q]
    article_hash = Array.new
    @name = get_company_cost_center('cost_center')
    articles = Subcontract.getOwnArticles(word, @name)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def show
    @subcontract = Subcontract.find(params[:id])
    render layout: false
  end
 
  def new
    @subcontract = Subcontract.new
    @suppliers = TypeEntity.find_by_name('Proveedores').entities
    @company = params[:company_id]
    @igv = FinancialVariable.find_by_name("IGV").value
    render layout: false
  end

  def create
    subcontract = Subcontract.new(subcontracts_parameters)
    subcontract.cost_center_id = get_company_cost_center('cost_center')
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
    @reg_n = (Time.now.to_f*1000).to_i
    ibb_id = params[:itembybudget_id].split("-")
    @id_itembybudget = ibb_id[0]
    name = Itembybudget.get_item_by_budget(ibb_id[0])
    name.each do |na|
      @name_itembybudget = na[2]
    end
    render(partial: 'subcontract_items', :layout => false)
  end

  def add_more_advance
    @advance = params[:advance]
    @date = params[:date]
    @reg_n = (Time.now.to_f*1000).to_i
    render(partial: 'subcontract_advance_items', :layout => false)
  end

  def edit
    @subcontract = Subcontract.find(params[:id])
    @suppliers = TypeEntity.find_by_name('Proveedores').entities
    @company = params[:company_id]
    @reg_n = (Time.now.to_f*1000).to_i
    @igv = FinancialVariable.find_by_name("IGV").value
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

  def getsc_prebudgets
    word = params[:q]
    part_hash = Array.new
    part = Itembybudget.get_item_by_budget(word)
    part.each do |art|
      part_hash << {'order' => art[0], 'id' => art[1].to_s+'-'+art[3].to_s,  'name' => art[2]}
    end
    render json: {:part => part_hash}    
  end

  private
  def subcontracts_parameters
    params.require(:subcontract).permit(
     :entity_id, 
     :valorization, 
     :terms_of_payment, 
     :initial_amortization_number, 
     :initial_amortization_percent, 
     :guarantee_fund, 
     :detraction, 
     :contract_amount, 
     :igv, 
     :type, 
     subcontract_details_attributes: [
       :id, 
       :subcontract_id, 
       :article_id, 
       :phase_id, 
       :amount, 
       :unit_price, 
       :partial, 
       :description, 
       :itembybudget_id,
       :_destroy
     ],
     subcontract_advances_attributes: [
       :id,
       :subcontract_id,
       :date_of_issue,
       :advance,
       :_destroy
     ]
    )
  end
end