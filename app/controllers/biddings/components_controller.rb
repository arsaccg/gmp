class Biddings::ComponentsController < ApplicationController
  def index
    @components = Component.all
    render layout: false
  end

  def show
    @component = Component.find(params[:id])
    render layout: false
  end

  def new
    @component = Component.new
    render layout: false
  end

  def create
    company = Component.new(components_params)
    if company.save
      flash[:notice] = "Se ha creado correctamente el nuevo componente de obra."
      redirect_to :action => :index
    else
      company.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @company = company
      render :new, layout: false
    end
  end

  def edit
    @component = Component.find(params[:id])
    render layout: false
  end

  def update
    component = Component.find(params[:id])
    if component.update_attributes(components_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      component.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @component = component
      render :edit, layout: false
    end
  end

  def destroy
    component = Component.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => component
  end

  private
  def components_params
    params.require(:component).permit(:name, :specialty)
  end
end
