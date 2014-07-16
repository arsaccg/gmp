class DocumentaryControl::TypeOfCompaniesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfComp = TypeOfCompany.where("company_id = ?", get_company_cost_center('company').to_s)
    render layout: false
  end

  def new
    @typeOfComp = TypeOfCompany.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfComp = TypeOfCompany.new(typeOfComp_parameters)
    typeOfComp.company_id = get_company_cost_center('company')
    if typeOfComp.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfComp.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfComp = typeOfComp
      render :new, layout: false
    end
  end

  def edit
    @typeOfComp = TypeOfCompany.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfComp = TypeOfCompany.find(params[:id])
    typeOfComp.company_id = get_company_cost_center('company')
    if typeOfComp.update_attributes(typeOfComp_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfComp.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfComp = typeOfComp
      render :edit, layout: false
    end
  end

  def destroy
    typeOfComp = TypeOfCompany.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfComp
  end

  private
  def typeOfComp_parameters
    params.require(:type_of_company).permit(:preffix, :name)
  end
end