class Libraries::TypeOfLawAndRegulationsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfLaw = TypeOfLawAndRegulation.all
    render layout: false
  end

  def new
    @typeOfLaw = TypeOfLawAndRegulation.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfLaw = TypeOfLawAndRegulation.new(typeOfLaw_parameters)
    if typeOfLaw.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfLaw.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfLaw = typeOfLaw
      render :new, layout: false
    end
  end

  def edit
    @typeOfLaw = TypeOfLawAndRegulation.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfLaw = TypeOfLawAndRegulation.find(params[:id])
    if typeOfLaw.update_attributes(typeOfLaw_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfLaw.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfLaw = typeOfLaw
      render :edit, layout: false
    end
  end

  def destroy
    typeOfLaw = TypeOfLawAndRegulation.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfLaw
  end

  private
  def typeOfLaw_parameters
    params.require(:type_of_law_and_regulation).permit(:preffix, :name)
  end
end