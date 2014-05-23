class Production::PositionWorkersController < ApplicationController
  def index
    @company = params[:company_id]
    @positionWorkers = PositionWorker.all
    render layout: false
  end

  def new
    @positionWorker = PositionWorker.new
    @company = params[:company_id]
    render layout: false
  end

  def create
    positionWorker = PositionWorker.new(position_worker_parameters)
    if positionWorker.save
      flash[:notice] = "Se ha creado correctamente el cargo del trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      positionWorker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @positionWorker = PositionWorker.find(params[:id])
    @company = params[:company_id]
    render layout: false
  end

  def update
    positionWorker = PositionWorker.find(params[:id])
    if positionWorker.update_attributes(position_worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      positionWorker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @positionWorker = positionWorker
      render :edit, layout: false
    end
  end

  private
  def position_worker_parameters
    params.require(:position_worker).permit(:name)
  end
end
