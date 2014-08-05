class Logistics::CostCenterDetailsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
     @cost_center_details = CostCenterDetail.all
    render layout: false
  end

  def show
    @cost_center_detail = CostCenterDetail.find(params[:id])
    render layout: false
  end

  def new
    @cost_center_detail = CostCenterDetail.new
    @cost_center_id = params[:cost_center_id]
    @companyselected = get_company_cost_center('company')
    @clients = TypeEntity.find_by_preffix("C").entities
    @contractors = TypeEntity.find_by_preffix("P").entities
    @totalPercentage=EntityCostCenterDetail.sum(:participation, :conditions => {:cost_center_detail_id => [@cost_center_detail.id]})    
    render layout: false
  end

  def create
    cost_center_detail = CostCenterDetail.new(cost_center_detail_params)
    if cost_center_detail.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, :controller => "cost_centers"
    else
      gexp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @cost_center_detail = cost_center_detail
      render :new, layout: false 
    end
  end

  def update
    cost_center_detail = CostCenterDetail.find(params[:id])
    if cost_center_detail.update_attributes(cost_center_detail_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "cost_centers"
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @cost_center_detail = cost_center_detail
      render :edit, layout: false
    end
  end

  def edit
    @reg_n=((Time.now.to_f)*100).to_i
    @clients = TypeEntity.find_by_preffix("C").entities
    @contractors = TypeEntity.find_by_preffix("P").entities
    @cost_center_detail = CostCenterDetail.find(params[:id])
    @cost_center_id = params[:cost_center_id]
    @companyselected = get_company_cost_center('company')
    @details=CostCenterDetail.all
    @action = 'edit'
    @totalPercentage=EntityCostCenterDetail.sum(:participation, :conditions => {:cost_center_detail_id => [@cost_center_detail.id]})
    render layout: false
  end

  def add_contractor_field
    @reg_n = ((Time.now.to_f)*100).to_i
    @contractor = Entity.find(params[:entity_id])
    @participation = params[:participation].to_f
    render(partial: 'contractors', :layout => false)
  end

  def destroy
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cost_center_detail
      @cost_center_detail = CostCenterDetail.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def cost_center_detail_params
      params.require(:cost_center_detail).permit(:name,:call_date,:snip_code,:process_number,:good_pro_date,:referential_value,:earned_value,:direct_cost,:general_cost,:utility,:IGV,:contract_sign_date,:contract_number,:land_delivery_date,:direct_advanced_payment_date,:cost_center_id,:amazon_tax_condition,:direct_advanced_form_date,:start_date_of_work,:procurement_system,:execution_term,:supervision,:entity_id,:material_advanced_payment_date, entity_cost_center_details_attributes: [:id, 
        :cost_center_detail_id,
        :entity_id, 
        :participation,:_destroy])
    end


end

