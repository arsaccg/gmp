class DocumentaryControl::TypeOfWorkReportsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfWo = TypeOfWorkReport.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfWo = TypeOfWorkReport.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfWo = TypeOfWorkReport.new(typeOfWo_parameters)
    typeOfWo.cost_center_id = get_company_cost_center('cost_center')
    if typeOfWo.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfWo.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfWo = typeOfWo
      render :new, layout: false
    end
  end

  def edit
    @typeOfWo = TypeOfWorkReport.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfWo = TypeOfWorkReport.find(params[:id])
    typeOfWo.cost_center_id = get_company_cost_center('cost_center')
    if typeOfWo.update_attributes(typeOfWo_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfWo.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfWo = typeOfWo
      render :edit, layout: false
    end
  end

  def destroy
    typeOfWo = TypeOfWorkReport.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfWo
  end

  private
  def typeOfWo_parameters
    params.require(:type_of_work_report).permit(:preffix, :name)
  end
end