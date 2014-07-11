class DocumentaryControl::ContestDocumentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_cont = TypeOfContestDocument.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @cont = ContestDocument.find(params[:id])
    render layout: false
  end

  def new
    @cont = ContestDocument.new
    @cost_center = get_company_cost_center('cost_center')
    render layout: false
  end

  def create
    flash[:error] = nil
    cont = ContestDocument.new(cont_parameters)
    cont.cost_center_id = get_company_cost_center('cost_center')
    if cont.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      cont.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @cont = cont
      render :new, layout: false 
    end
  end

  def edit
    @cont = ContestDocument.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    cont = ContestDocument.find(params[:id])
    cont.cost_center_id = get_company_cost_center('cost_center')
    if cont.update_attributes(cont_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      cont.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @cont = cont
      render :edit, layout: false
    end
  end

  def destroy
    cont = ContestDocument.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => cont
  end

  private
  def cont_parameters
    params.require(:contest_document).permit(:name, :description, :document, {:type_of_contest_document_ids => []})
  end
end