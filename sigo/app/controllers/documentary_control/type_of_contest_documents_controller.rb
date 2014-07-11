class DocumentaryControl::TypeOfContestDocumentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfCont = TypeOfContestDocument.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfCont = TypeOfContestDocument.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfCont = TypeOfContestDocument.new(typeOfCont_parameters)
    typeOfCont.cost_center_id = get_company_cost_center('cost_center')
    if typeOfCont.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfCont.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfCont = typeOfCont
      render :new, layout: false
    end
  end

  def edit
    @typeOfCont = TypeOfContestDocument.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfCont = TypeOfContestDocument.find(params[:id])
    typeOfCont.cost_center_id = get_company_cost_center('cost_center')
    if typeOfCont.update_attributes(typeOfCont_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfCont.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfCont = typeOfCont
      render :edit, layout: false
    end
  end

  def destroy
    typeOfCont = TypeOfContestDocument.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfCont
  end

  private
  def typeOfCont_parameters
    params.require(:type_of_contest_document).permit(:preffix, :name)
  end
end