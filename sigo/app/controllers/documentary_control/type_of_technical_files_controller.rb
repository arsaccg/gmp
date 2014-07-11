class DocumentaryControl::TypeOfTechnicalFilesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfTec = TypeOfTechnicalFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfTec = TypeOfTechnicalFile.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfTec = TypeOfTechnicalFile.new(typeOfTec_parameters)
    typeOfTec.cost_center_id = get_company_cost_center('cost_center')
    if typeOfTec.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfTec.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfTec = typeOfTec
      render :new, layout: false
    end
  end

  def edit
    @typeOfTec = TypeOfTechnicalFile.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfTec = TypeOfTechnicalFile.find(params[:id])
    typeOfTec.cost_center_id = get_company_cost_center('cost_center')
    if typeOfTec.update_attributes(typeOfTec_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfTec.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfTec = typeOfTec
      render :edit, layout: false
    end
  end

  def destroy
    typeOfTec = TypeOfTechnicalFile.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfTec
  end

  private
  def typeOfTec_parameters
    params.require(:type_of_technical_file).permit(:preffix, :name)
  end
end