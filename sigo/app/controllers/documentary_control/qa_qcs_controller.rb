class DocumentaryControl::QaQcsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type = params[:type]
    if params[:type] == '0'
      @type_qq =  TypeOfQaQc.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s)
    end
    if params[:type] == '1'
      @type_qq = TypeOfQaQcSupplier.where("cost_center_id = "+ get_company_cost_center('cost_center').to_s)
    end
    render layout: false
  end

  def show
    @qac = QaQc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @type = params[:type]
    if @type == '0'
      @type_qq = TypeOfQaQc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    else      
      @type_qqs = TypeOfQaQcSupplier.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    end
    @cost_center = get_company_cost_center('cost_center')
    @qac = QaQc.new
    render layout: false
  end

  def create
    flash[:error] = nil
    qac = QaQc.new(qac_parameters)
    qac.cost_center_id = get_company_cost_center('cost_center')
    if qac.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index, :type=>params[:type]
    else
      qac.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @qac = qac
      render :new, layout: false, :type=>params[:type]
    end
  end

  def edit
    @type = params[:type]
    if @type == '0'
      @type_qq = TypeOfQaQc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    else      
      @type_qqs = TypeOfQaQcSupplier.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    end    
    @type_qq = TypeOfQaQc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @qac = QaQc.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    qac = QaQc.find(params[:id])
    qac.cost_center_id = get_company_cost_center('cost_center')
    if qac.update_attributes(qac_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id], :type=>params[:type]
    else
      qac.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @qac = qac
      render :edit, layout: false, :type=>params[:type]
    end
  end

  def valorization
    word = params[:wordtosearch]
    @wor = QaQc.where('name LIKE "%'+vald.to_s+'%" OR description LIKE "%'+vald.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def destroy
    qac = QaQc.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => qac
  end

  private
  def qac_parameters
    params.require(:qa_qc).permit(:name, :description, :document, :type_of_qa_qc_id, :type_of_qa_qc_supplier_id)
  end
end
