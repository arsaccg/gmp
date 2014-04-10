class Biddings::TrainingController < ApplicationController
  def index
    @training = Training.all
    render layout: false
  end

  def show
  end

  def new
    @training = Training.new
    render :new, layout: false
  end

  def create
    @professional= Professional.all
    training = Training.new(training_parameters)
    if training.save
      flash[:notice] = "Se ha creado correctamente la nueva compañia."
      redirect_to :action => :index
    else
      training.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    # Load new()
    @training = training
    render :new, layout: false
    end
  end

  def edit
    @professional= Professional.all
    @training = Training.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
  end

  def delete
    training = training.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => training
  end
  private
  def training_parameters
    params.require(:training).permit(:professional_id, :type_training, :training)
  end
end
