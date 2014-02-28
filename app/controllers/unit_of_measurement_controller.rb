class UnitOfMeasurementController < ApplicationController
  def index
    @unitOfMeasures = UnitOfMeasurement.all
    render layout: false
  end

  def create
    @unitOfMeasure = UnitOfMeasurement.new(unit_of_measure_params)
    if @unitOfMeasure.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => 'index'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => 'index'
    end
  end

  def edit
  end

  def show
  end

  def update
  end

  def new
    @unitOfMeasure = UnitOfMeasurement.new
    render :layout => false
  end

  def destroy
  end

  private
    def unit_of_measure_params
      params.required(:unit_of_measurement).permit(:name)
    end

end
