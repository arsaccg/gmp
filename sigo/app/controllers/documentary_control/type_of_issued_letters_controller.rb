class DocumentaryControl::TypeOfIssuedLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfIss = TypeOfIssuedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfIss = TypeOfIssuedLetter.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfIss = TypeOfIssuedLetter.new(typeOfIss_parameters)
    typeOfIss.cost_center_id = get_company_cost_center('cost_center')
    if typeOfIss.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfIss.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfIss = typeOfIss
      render :new, layout: false
    end
  end

  def edit
    @typeOfIss = TypeOfIssuedLetter.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfIss = TypeOfIssuedLetter.find(params[:id])
    typeOfIss.cost_center_id = get_company_cost_center('cost_center')
    if typeOfIss.update_attributes(typeOfIss_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfIss.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfIss = typeOfIss
      render :edit, layout: false
    end
  end

  def destroy
    typeOfIss = TypeOfIssuedLetter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfIss
  end

  private
  def typeOfIss_parameters
    params.require(:type_of_issued_letter).permit(:preffix, :name)
  end
end