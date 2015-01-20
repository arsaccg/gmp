class Payrolls::TypeOfPayslipsController < ApplicationController
before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @tpay = TypeOfPayslip.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @tpay = TypeOfPayslip.find(params[:id])
    render layout: false
  end

  def new
    @tpay = TypeOfPayslip.new
    @others_payslips = TypeOfPayslip.select(:name).select(:id)
    render layout: false
  end

  def create
    flash[:error] = nil
    tpay = TypeOfPayslip.new(tpay_parameters)
    tpay.cost_center_id = get_company_cost_center('cost_center')
    if tpay.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      tpay.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @tpay = tpay
      render :new, layout: false 
    end
  end

  def edit
    @tpay = TypeOfPayslip.find(params[:id])
    @others_payslips = TypeOfPayslip.select(:name).select(:id).where('id <> ?', @tpay.id)
    @action = 'edit'
    render layout: false
  end

  def update
    tpay = TypeOfPayslip.find(params[:id])
    if tpay.update_attributes(tpay_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      tpay.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @tpay = tpay
      render :edit, layout: false
    end
  end

  def destroy
    tpay = TypeOfPayslip.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => tpay
  end

  private
  def tpay_parameters
    params.require(:type_of_payslip).permit(
      :name, 
      :description, 
      :for_worker_employee, 
      :type_of_worker_id, 
      {:concept_ids => []},
      :type_of_payslips_id,
      :type_operation,
      :type_converted_operation,
      :name_operation
    )
  end
end
