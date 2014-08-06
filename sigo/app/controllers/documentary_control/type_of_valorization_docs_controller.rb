class DocumentaryControl::TypeOfValorizationDocsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeVal = TypeOfValorizationDoc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeVal = TypeOfValorizationDoc.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeVal = TypeOfValorizationDoc.new(typeVal_parameters)
    typeVal.cost_center_id = get_company_cost_center('cost_center')
    if typeVal.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeVal.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeVal = typeVal
      render :new, layout: false
    end
  end

  def edit
    @typeVal = TypeOfValorizationDoc.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeVal = TypeOfValorizationDoc.find(params[:id])
    typeVal.cost_center_id = get_company_cost_center('cost_center')
    if typeVal.update_attributes(typeVal_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeVal.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeVal = typeVal
      render :edit, layout: false
    end
  end

  def destroy
    typeVal = TypeOfValorizationDoc.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeVal
  end

  private
  def typeVal_parameters
    params.require(:type_of_valorization_doc).permit(:preffix, :name)
  end
end