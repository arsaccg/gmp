class Logistics::CategoriesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @categories = Category.all
    if params[:task] == 'created' || params[:task] == 'edited'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def show
  end

  def new
    @category = Category.new
    render layout: false
  end

  def create
    category = Category.new(category_parameters)
    if category.save
      flash[:notice] = "Se ha creado correctamente la nueva categoria."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, :task => 'failed'
    end
  end

  def update
    category = Category.find(params[:id])
    category.update_attributes(category_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def edit
    @category = Category.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def destroy
    category = Category.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def category_parameters
    params.require(:category).permit(:code, :name)
  end
end
