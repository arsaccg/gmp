class Biddings::MajorsController < ApplicationController
  def index
    flash[:error] = nil
    @major = Major.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @major = Major.new
    render layout: false
  end

  def create
    flash[:error] = nil
    major = Major.new(major_parameters)
    if major.save
      flash[:notice] = "Se ha creado correctamente la profesión."
      redirect_to :action => :index
    else
      major.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @major = Major.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    major = Major.find(params[:id])
    if major.update_attributes(charge_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      major.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @major = major
      render :edit, layout: false
    end
  end

  def delete
    major = Major.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la profesión."
    render :json => major
  end

  private
  def major_parameters
    params.require(:major).permit(:name)
  end
end
