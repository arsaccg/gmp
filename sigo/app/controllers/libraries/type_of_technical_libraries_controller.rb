class Libraries::TypeOfTechnicalLibrariesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfTech = TypeOfTechnicalLibrary.all
    render layout: false
  end

  def new
    @typeOfTech = TypeOfTechnicalLibrary.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfTech = TypeOfTechnicalLibrary.new(typeOfTech_parameters)
    if typeOfTech.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfTech.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfTech = typeOfTech
      render :new, layout: false
    end
  end

  def edit
    @typeOfTech = TypeOfTechnicalLibrary.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfTech = TypeOfTechnicalLibrary.find(params[:id])
    if typeOfTech.update_attributes(typeOfTech_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfTech.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfTech = typeOfTech
      render :edit, layout: false
    end
  end

  def destroy
    typeOfTech = TypeOfTechnicalLibrary.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfTech
  end

  private
  def typeOfTech_parameters
    params.require(:type_of_technical_library).permit(:preffix, :name)
  end
end