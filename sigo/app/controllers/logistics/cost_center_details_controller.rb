class Logistics::CostCenterDetailsController < ApplicationController
  def index
     @cost_center_details = CostCenterDetail.all
    render layout: false
  end

  def show
    @cost_center_detail = CostCenterDetail.find(params[:id])
    render layout: false
  end

  def new
    @reg_n=((Time.now.to_f)*100).to_i
    @cost_center_detail = CostCenterDetail.new
    @cost_center_detail.entity_cost_center_detail.build
    @cost_center_id = params[:cost_center_id]
    @companyselected = get_company_cost_center('company')
    @clients = TypeEntity.find_by_preffix("C").entities
    @contractors = TypeEntity.find_by_preffix("P").entities    
    render layout: false
  end

  def create
    @cost_center_detail = CostCenterDetail.new(cost_center_detail_params)

    respond_to do |format|
      if @cost_center_detail.save
        format.html { redirect_to root_path, notice: 'Se ha registrado los datos correctamente.' }
        format.json { render :show, status: :created, location: @cost_center_detail }
      else
        format.html { render :new }
        format.json { render json: root_path.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
     @cost_center_detail = CostCenterDetail.find(params[:id])
     @cost_center_id = params[:cost_center_id]
    
      if @cost_center_detail.update(cost_center_detail_params)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to root_path
      else
        format.html { render :edit }
        format.json { render json: @cost_center_detail.errors, status: :unprocessable_entity }
      end
      
  end

  def edit
    @clients = TypeEntity.find_by_preffix("C").entities
    @contractors = TypeEntity.find_by_preffix("P").entities
    @cost_center_detail = CostCenterDetail.find(params[:id])
    @cost_center_id = params[:cost_center_id]
    @companyselected = get_company_cost_center('company')
    @details=CostCenterDetail.all
    @action = 'edit'
    render layout: false
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
        :participation])
    end


end

