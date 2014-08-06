class DocumentaryControl::TypeOfModificationFilesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfMo = TypeOfModificationFile.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfMo = TypeOfModificationFile.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfMo = TypeOfModificationFile.new(typeOfMo_parameters)
    typeOfMo.cost_center_id = get_company_cost_center('cost_center')
    if typeOfMo.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfMo.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfMo = typeOfMo
      render :new, layout: false
    end
  end

  def edit
    @typeOfMo = TypeOfModificationFile.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfMo = TypeOfModificationFile.find(params[:id])
    typeOfMo.cost_center_id = get_company_cost_center('cost_center')
    if typeOfMo.update_attributes(typeOfMo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfMo.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfMo = typeOfMo
      render :edit, layout: false
    end
  end

  def destroy
    typeOfMo = TypeOfModificationFile.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfMo
  end

  private
  def typeOfMo_parameters
    params.require(:type_of_modification_file).permit(:preffix, :name)
  end
end