class DocumentaryControl::TypeOfContractualDocumentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfContra = TypeOfContractualDocument.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfContra = TypeOfContractualDocument.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfContra = TypeOfContractualDocument.new(typeOfContra_parameters)
    typeOfContra.cost_center_id = get_company_cost_center('cost_center')
    if typeOfContra.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfContra.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfContra = typeOfContra
      render :new, layout: false
    end
  end

  def edit
    @typeOfContra = TypeOfContractualDocument.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfContra = TypeOfContractualDocument.find(params[:id])
    typeOfContra.cost_center_id = get_company_cost_center('cost_center')
    if typeOfContra.update_attributes(typeOfContra_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfContra.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfContra = typeOfContra
      render :edit, layout: false
    end
  end

  def destroy
    typeOfContra = TypeOfContractualDocument.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfContra
  end

  private
  def typeOfContra_parameters
    params.require(:type_of_contractual_document).permit(:preffix, :name)
  end
end