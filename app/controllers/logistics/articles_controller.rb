class Logistics::ArticlesController < ApplicationController
  before_filter :authenticate_user!
  def index
    @Article = Article.all
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def create
    article = Article.new(article_parameters)
    if article.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, :task => 'failed'
    end
  end

  def edit
    @article = Article.find(params[:id])
    @unitOfMeasurement = UnitOfMeasurement.all
    @action = 'edit'
    render layout: false
  end

  def show
    article = Article.find(params[:id])
    render :show
  end

  def update
    article = Article.find(params[:id])
    article.update_attributes(article_parameters)
    flash[:notice] = "Se ha actualizado correctamente los datos."
    redirect_to :action => :index, :task => 'edited'
  end

  def new
    @article = Article.new
    @unitOfMeasurement = UnitOfMeasurement.all
    render layout: false
  end

  def destroy
    article = Article.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el articulo seleccionado."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def article_parameters
    params.require(:article).permit(:name, :description, :unit_of_measurement_id)
  end
end