class Biddings::TrainingsController < ApplicationController
  def index
    flash[:error] = nil
    @training = Training.all
    @professional = Professional.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @training = Training.new
    @professional = Professional.all
    render layout: false
  end

  def create
    flash[:error] = nil
    training = Training.new(training_parameters)
    if training.save
      flash[:notice] = "Se ha creado correctamente la capacitación."
      redirect_to :action => :index
    else
      training.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @training = Training.find(params[:id])
    @professional = Professional.all
    @action = 'edit'
    render layout: false
  end

  def update
    training = Training.find(params[:id])
    if training.update_attributes(training_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      training.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @training = training
      render :edit, layout: false
    end
  end

  def destroy
    training = Training.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la capacitación seleccionada."
    render :json => training
  end

  private
  def training_parameters
    params.require(:training).permit(:professional_id, :type_training, :training)
  end
end
