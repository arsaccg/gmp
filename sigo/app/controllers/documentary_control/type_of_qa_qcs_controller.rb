class DocumentaryControl::TypeOfQaQcsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfQq = TypeOfQaQc.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfQq = TypeOfQaQc.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfQq = TypeOfQaQc.new(typeOfQq_parameters)
    typeOfQq.cost_center_id = get_company_cost_center('cost_center')
    if typeOfQq.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfQq.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfQq = typeOfQq
      render :new, layout: false
    end
  end

  def edit
    @typeOfQq = TypeOfQaQc.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfQq = TypeOfQaQc.find(params[:id])
    typeOfQq.cost_center_id = get_company_cost_center('cost_center')
    if typeOfQq.update_attributes(typeOfQq_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfQq.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfQq = typeOfQq
      render :edit, layout: false
    end
  end

  def destroy
    typeOfQq = TypeOfQaQc.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfQq
  end

  private
  def typeOfQq_parameters
    params.require(:type_of_qa_qc).permit(:preffix, :name)
  end
end