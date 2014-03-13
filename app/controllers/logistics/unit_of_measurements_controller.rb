class Logistics::UnitOfMeasurementsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    @unitOfMeasures = UnitOfMeasurement.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def show
    @unitOfMeasure = UnitOfMeasurement.find(params[:id])
    render :show
  end

  def new
    @unitOfMeasure = UnitOfMeasurement.new
    render :new, layout: false
  end

  def create
    unitOfMeasure = UnitOfMeasurement.new(unit_of_measure_parameters)
    if unitOfMeasure.save
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      unitOfMeasure.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. "
      render layout: false
    end

  end

  def edit
    @unitOfMeasure = UnitOfMeasurement.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    unitOfMeasure = UnitOfMeasurement.find(params[:id])
    unitOfMeasure.update_attributes(unit_of_measure_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index
  end

  def destroy
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  private
  def unit_of_measure_parameters
    params.require(:unit_of_measurement).permit(:name, :symbol, :code)
  end

end