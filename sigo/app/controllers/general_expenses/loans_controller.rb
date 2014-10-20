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

  def display_workers
    word = params[:q]
    workers_hash = Array.new
    workers = Loan.getWorkers(word)
    workers.each do |art|
      workers_hash << {'name' => art[1],"paternal_surname"=> art[2],"maternal_surname"=> art[3],"id"=> art[0],"dni"=> art[4]}
    end
    render json: {:workers => workers_hash}
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
    @cc = CostCenter.find(params[:cc_id])
    @presto = Loan.where('cost_center_lender_id=?', @cc.id)
    @prestaron = Loan.where('cost_center_beneficiary_id=?', @cc.id)
    @ledeben = Array.new
    @debe = Array.new
    ledeben = ActiveRecord::Base.connection.execute("
      SELECT cost_center_beneficiary_id
      FROM  loans
      WHERE  cost_center_lender_id ="+@cc.id.to_s+"
      GROUP BY cost_center_beneficiary_id
    ")
    ledeben.each do |ld|
      aldp=0
      aldd=0
      ldp = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_lender_id ="+@cc.id.to_s+"
        AND cost_center_beneficiary_id = "+ld[0].to_s+"
        AND state = 1
      ")
      ldp.each do |ldp|
        aldp=ldp[0]
      end
      ldd = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_lender_id ="+@cc.id.to_s+"
        AND cost_center_beneficiary_id = "+ld[0].to_s+"
        AND state = 2
      ")
      ldd.each do |ldp|
        aldd=ldp[0]
      end
      @ledeben << [ld[0].to_s,aldp,aldd]
    end

    debe = ActiveRecord::Base.connection.execute("
      SELECT cost_center_lender_id
      FROM  loans
      WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
      GROUP BY cost_center_lender_id
    ")

    debe.each do |ld|
      aldp=0
      aldd=0
      ldp = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
        AND cost_center_lender_id = "+ld[0].to_s+"
        AND state = 1
      ")
      ldp.each do |ldp|
        aldp=ldp[0]
      end
      ldd = ActiveRecord::Base.connection.execute("
        SELECT Sum(amount)
        FROM  loans
        WHERE  cost_center_beneficiary_id ="+@cc.id.to_s+"
        AND cost_center_lender_id = "+ld[0].to_s+"
        AND state = 2
      ")
      ldd.each do |ldp|
        aldd=ldp[0]
      end
      @debe << [ld[0].to_s,aldp,aldd]
    end    
    render layout: false
  end

  def show
    @type = params[:type]
    @cost_center1 = CostCenter.find(params[:cc1])
    @cost_center2 = CostCenter.find(params[:cc2])
    @cc = params[:cc3]
    @loan = Loan.where("cost_center_lender_id = ? AND cost_center_beneficiary_id = ?",@cost_center1.id, @cost_center2.id)
    @total = 0
    @devuelto = 0
    @loan.each do |loan|
      @total+= loan.amount
      if loan.state == "2"
        @devuelto += loan.amount
      end
    end
    render layout: false
  end

  def show_details 
    @loan= Loan.find(params[:id])
    render(partial: 'show_detail', :layout => false)
  end  
end
