class Payrolls::TypeOfPayslipsController < ApplicationController
before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @tpay = TypeOfPayslip.all
    render layout: false
  end

  def show
    @tpay = TypeOfPayslip.find(params[:id])
    render layout: false
  end

  def new
    @tpay = TypeOfPayslip.new
    render layout: false
  end

  def create
    flash[:error] = nil
    tpay = TypeOfPayslip.new(tpay_parameters)
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
    @action = 'edit'
    render layout: false
  end

  def update
    tpay = TypeOfPayslip.find(params[:id])
    ActiveRecord::Base.connection.execute("DELETE FROM `concepts_type_of_payslips` WHERE `type_of_payslip_id` = "+tpay.id.to_s)
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
    params.require(:type_of_payslip).permit(:name, :description, :type_of_worker, {:concept_ids => []})
  end
end
