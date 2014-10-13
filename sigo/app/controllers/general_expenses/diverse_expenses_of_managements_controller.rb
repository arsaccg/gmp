class GeneralExpenses::DiverseExpensesOfManagementsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @cc = CostCenter.find(params[:cc_id].to_s)
    @gdg = DiverseExpensesOfManagement.where("cost_center_id ="+@cc.id.to_s)
    render layout: false
  end

  def show
    flash[:error] = nil
    @gdg = DiverseExpensesOfManagement.find(params[:id])
    render :show
  end

  def new
    @cc = CostCenter.find(params[:cc_id].to_s)
    @gdg = DiverseExpensesOfManagement.new
    render layout: false
  end

  def create_expense
    flash[:error] = nil
    gdg = DiverseExpensesOfManagement.new
    gdg.name = params[:name]
    gdg.percentage = params[:percentage]
    gdg.amount = params[:amount]
    gdg.expenses = params[:expenses]
    gdg.cost_center_id = params[:cc_id]
    gdg.total_delivered = 0
    if gdg.save
      gdg.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render json: {:cc_id=>gdg.cost_center_id.to_s}
  end
  
  def create
  end

  def edit
    @gdg = DiverseExpensesOfManagement.find(params[:id])
    @action = 'edit'
    @proveedor = TypeEntity.find_by_preffix('P').entities
    @reg_n = ((Time.now.to_f)*100).to_i
    render layout: false
  end

  def update
    flash[:error] = nil
    gdg = DiverseExpensesOfManagement.find(params[:id])
    if gdg.update_attributes(gdg_parameters)
      @total = 0
      gdg.diverse_expenses_of_management_details.each do |total|
        @total = @total.to_f + total.amount.to_f
      end
      ActiveRecord::Base.connection.execute("UPDATE diverse_expenses_of_managements SET total_delivered='"+@total.to_f.to_s+"' WHERE id="+gdg.id.to_s)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      gdg.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @gdg = gdg
      render :edit, layout: false
    end
  end

  def show_summary_table
    @gdg = DiverseExpensesOfManagement.find(params[:id])
    render(:partial => 'table_deliveries', :layout => false)
  end

  def add_deliveries
    @montoe = params[:montoe]
    @fechae = params[:fechae]
    @proveedore = Entity.find(params[:proveedore])
    @conceptoe = params[:conceptoe]
    @fechafae = params[:fechafae]
    @montofae = params[:montofae]
    @detraccionfae = params[:detraccionfae]
    @acuentafae = params[:acuentafae]
    @igvfae = params[:igvfae]
    @net_return = @acuentafae.to_f - @igvfae.to_f
    @code = params[:code]
    @factura = params[:factura]
    @balance = @montoe.to_f - @net_return.to_f
    @reg_n = ((Time.now.to_f)*100).to_i
    render(partial: 'deliveries', :layout => false)
  end

  def destroy
    gdg = DiverseExpensesOfManagement.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => gdg
  end

  private
  def gdg_parameters
    params.require(:diverse_expenses_of_management).permit(:name, :percentage, :amount, :expenses, :total_delivered, diverse_expenses_of_management_details_attributes: [
        :id, 
        :diverse_expenses_of_management_id,
        :amount,
        :delivered_date,
        :entity_id,
        :code,
        :bill,
        :bill_concept,
        :bill_date,
        :bill_amount,
        :bill_detraction,
        :bill_to_account,
        :igv_commission,
        :net_return,
        :balance,
        :_destroy
      ])
  end
end