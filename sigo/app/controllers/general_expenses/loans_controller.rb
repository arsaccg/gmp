class GeneralExpenses::LoansController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def new
    @costcenters = CostCenter.where('id not in (?)', params[:cc_id])
    @cc = CostCenter.find(get_company_cost_center('cost_center')) rescue nil
    @loan = Loan.new
    render layout: false
  end

  def create

  end

  def create_loan
    flash[:error] = nil
    loan = Loan.new
    loan.person = params[:person]
    loan.loan_date = params[:loan_date]
    loan.loan_type = params[:loan_type]
    loan.amount = params[:amount]
    loan.description = params[:description]
    loan.refund_type = params[:refund_type]
    loan.check_number = params[:check_number]
    loan.check_date = params[:check_date]
    loan.state = params[:state]
    loan.refund_date = params[:refund_date]
    loan.cost_center_beneficiary_id = params[:cost_center_beneficiary_id]
    loan.cost_center_lender_id = params[:cost_center_lender_id]
    if loan.save
      loan.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render json: {:cc_id=>loan.cost_center_lender_id.to_s}
  end

  def update
    loan = Loan.find(params[:id])
    if loan.update_attributes(loan_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "warehouse_orders"
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @loan = loan
      render :edit, layout: false
    end
  end

  def edit
    @reg_n=((Time.now.to_f)*100).to_i
    @loan = Loan.find(params[:id])
    @cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @action = 'edit'
    render layout: false
  end

  def destroy
    loan = Loan.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el pedido seleccionado."
    render :json => loan
  end

  def index
    @cc = CostCenter.find(get_company_cost_center('cost_center'))
    @presto = Loan.where('cost_center_lender_id=?', @cc.id)
    @prestaron = Loan.where('cost_center_beneficiary_id=?', @cc.id)
    render layout: false
  end

  def show
    @type = params[:type]
    @cost_center1 = CostCenter.find(params[:cc1])
    @cost_center2 = CostCenter.find(params[:cc2])
    @loan = Loan.where("cost_center_lender_id = ? AND cost_center_beneficiary_id = ?",@cost_center1.id, @cost_center2.id)
    @total = 0
    @devuelto = 0
    @loan.each do |loan|
      @total+= loan.amount
      if loan.state == 2
        @devuelto += loan.amount
      end
    end
    render layout: false
  end
end
