class DocumentaryControl::WorkReportsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_wor = TypeOfWorkReport.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @wor = WorkReport.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @type_wor = TypeOfWorkReport.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @wor = WorkReport.new
    render layout: false
  end

  def create
    flash[:error] = nil
    wor = WorkReport.new(wor_parameters)
    wor.cost_center_id = get_company_cost_center('cost_center')
    if wor.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      wor.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @wor = wor
      render :new, layout: false 
    end
  end

  def edit
    @cost_center = get_company_cost_center('cost_center')
    @wor = WorkReport.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    wor = WorkReport.find(params[:id])
    wor.cost_center_id = get_company_cost_center('cost_center')
    if wor.update_attributes(wor_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      wor.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @wor = wor
      render :edit, layout: false
    end
  end

  def destroy
    wor = WorkReport.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => wor
  end

  def work_reports
    word = params[:wordtosearch]
    @wor = WorkReport.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def wor_parameters
    params.require(:work_report).permit(:name, :description, :document, :type_of_work_report_id)
  end
end