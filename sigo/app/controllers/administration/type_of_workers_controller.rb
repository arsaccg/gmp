class Administration::TypeOfWorkersController < ApplicationController

  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    @type_of_worker = TypeOfWorker.all
    render layout: false
  end

  def show
  end

  def new
    @type_of_worker = TypeOfWorker.new
    render layout: false
  end

  def create
    type_of_worker = TypeOfWorker.new(type_of_worker_parameters)
    if type_of_worker.save
      flash[:notice] = "Se ha creado correctamente el nuevo tipo de entidad."
      redirect_to :action => :index
    else
      type_of_worker.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @type_of_worker = type_of_worker
      render :new, layout: false
    end
  end

  def edit
    @type_of_worker = TypeOfWorker.find(params[:id])
    render layout: false
  end

  def update
    type_of_worker = TypeOfWorker.find(params[:id])
    if type_of_worker.update_attributes(type_of_worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      type_of_worker.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @type_of_worker = type_of_worker
      render :edit, layout: false
    end
  end

  def destroy
    @type_of_worker = TypeOfWorker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => @type_of_worker
  end

  private
  def type_of_worker_parameters
    params.require(:type_of_worker).permit(:name, :prefix, :description, :worker_type)
  end
end
