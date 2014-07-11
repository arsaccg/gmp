class DocumentaryControl::TypeOfReceivedLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfRec = TypeOfReceivedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfRec = TypeOfReceivedLetter.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfRec = TypeOfReceivedLetter.new(typeOfRec_parameters)
    typeOfRec.cost_center_id = get_company_cost_center('cost_center')
    if typeOfRec.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfRec.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfRec = typeOfRec
      render :new, layout: false
    end
  end

  def edit
    @typeOfRec = TypeOfReceivedLetter.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfRec = TypeOfReceivedLetter.find(params[:id])
    typeOfRec.cost_center_id = get_company_cost_center('cost_center')
    if typeOfRec.update_attributes(typeOfRec_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfRec.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfRec = typeOfRec
      render :edit, layout: false
    end
  end

  def destroy
    typeOfRec = TypeOfReceivedLetter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfRec
  end

  private
  def typeOfRec_parameters
    params.require(:type_of_received_letter).permit(:preffix, :name)
  end
end