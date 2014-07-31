class Logistics::EntityCostCenterDetailsController < ApplicationController
  def new
    
  cost_center_detail = CostCenterDetail.find(params[:cost_center_detail_id])
  @entity_cost_center_detail = cost_center_detail.entity_cost_center_details.create
  new_entity_cost_center_detail_form = render_to_string :layout => false
  new_entity_cost_center_detail_form.gsub!("[#{@entity_cost_center_detail.id}]", "[#{Time.now.to_i}]")
  render :text => new_entidad_form, :layout => false
  end

  def show
    @entity_cost_center_detail = EntityCostCenterDetail.find(params[:id])
    render layout: false
  end

  def create
    @entity_cost_center_detail = EntityCostCenterDetail.new(entity_cost_center_detail_params)

    respond_to do |format|
      if @entity_cost_center_detail.save
        format.html { redirect_to root_path, notice: 'Se ha registrado los datos correctamente.' }
        format.json { render :show, status: :created, location: @entity_cost_center_detail }
      else
        format.html { render :new }
        format.json { render json: root_path.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
  end

  def edit

  end

  def destroy
    cost_center_detail = CostCenterDetail.find(params[:cost_center_detail_id])
  unless cost_center_detail.entity_cost_center_details.exists?(params[:id])
    render :text => { :success => false, :msg => 'the child was not found.' }.to_json and return
  end
  if cost_center_detail.entity_cost_center_details.destroy(params[:id])
render :text => { :success => true }.to_json
  else
    render :text => { :success => false, :msg => 'something unexpected happened.' }.to_json
  end
  end

  def index
  end

  private

  def entity_cost_center_detail_params
    params.require(:entity_cost_center_detail).permit(:cost_center_detail_id,:entity_id,:participation)
  end

end
