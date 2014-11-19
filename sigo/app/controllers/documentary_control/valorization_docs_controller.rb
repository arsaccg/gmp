class DocumentaryControl::ValorizationDocsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_val = TypeOfValorizationDoc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @val = ValorizationDoc.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @type_val = TypeOfValorizationDoc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @val = ValorizationDoc.new
    render layout: false
  end

  def create
    flash[:error] = nil
    val = ValorizationDoc.new(val_parameters)
    val.cost_center_id = get_company_cost_center('cost_center')
    if val.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      val.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @val = val
      render :new, layout: false 
    end
  end

  def edit
    @cost_center = get_company_cost_center('cost_center')
    @val = ValorizationDoc.find(params[:id])
    @type_val = TypeOfValorizationDoc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    val = ValorizationDoc.find(params[:id])
    val.cost_center_id = get_company_cost_center('cost_center')
    if val.update_attributes(val_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      val.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @val = val
      render :edit, layout: false
    end
  end

  def destroy
    val = ValorizationDoc.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => val
  end

  def valorization
    word = params[:wordtosearch]
    @wor = ValorizationDoc.where('name LIKE "%'+vald.to_s+'%" OR description LIKE "%'+vald.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def val_parameters
    params.require(:valorization_doc).permit(:name, :description, :document, :type_of_valorization_doc_id)
  end
end