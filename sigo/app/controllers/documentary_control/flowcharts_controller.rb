class DocumentaryControl::FlowchartsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @flow = Flowchart.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @flow = Flowchart.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @flow = Flowchart.new
    render layout: false
  end

  def create
    flash[:error] = nil
    flow = Flowchart.new(flow_parameters)
    flow.cost_center_id = get_company_cost_center('cost_center')
    if flow.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      flow.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @flow = flow
      render :new, layout: false 
    end
  end

  def edit
    @flow = Flowchart.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    flow = Flowchart.find(params[:id])
    flow.cost_center_id = get_company_cost_center('cost_center')
    if flow.update_attributes(flow_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      flow.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @flow = flow
      render :edit, layout: false
    end
  end

  def destroy
    flow = Flowchart.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => flow
  end

  private
  def flow_parameters
    params.require(:qa_qc).permit(:name, :description, :photo)
  end
end