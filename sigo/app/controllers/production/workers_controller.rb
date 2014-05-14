class Production::WorkersController < ApplicationController
  def index
    @company = params[:company_id]
    @workers = Worker.all
    render layout: false
  end

  def show
    @worker = Worker.find(params[:id])
    render layout: false
  end

  def new
    @worker = Worker.new
    @categoryOfWorkers = CategoryOfWorker.all
    @company = params[:company_id]
    @banks = Bank.all
    render layout: false
  end

  def create
    worker = Worker.new(worker_parameters)
    if worker.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @worker = Worker.find(params[:id])
    @categoryOfWorkers = CategoryOfWorker.all
    @company = params[:company_id]
    @action = 'edit'
    render layout: false
  end

  def update
    worker = Worker.find(params[:id])
    if worker.update_attributes(worker_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      worker.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @worker = worker
      render :edit, layout: false
    end
  end

  def destroy
    worker = Worker.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el trabajador."
    render :json => worker
  end

  private
  def worker_parameters
    params.require(:worker).permit(:first_name, :paternal_surname, :maternal_surname, :dni, :email, :phone, :date_of_birth, :address, :category_of_worker_id, :second_name)
  end
end