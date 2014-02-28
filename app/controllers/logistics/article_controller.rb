class Logistics::ArticleController < ApplicationController
  def index
    @Article = Article.all
    render layout: false
  end

  def create
    article = Article.new(article_parameters)
    if article.save
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => :index
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      render :new
    end
  end

  def edit
    article = Article.find(params[:id])
    render :edit
  end

  def show
    article = Article.find(params[:id])
    render :show
  end

  def update
    article = Article.find(params[:id])
  end

  def new
    @Article = Article.new
    render :new
  end

  def destroy
  end

  private
  def article_parameters
    params.require(:article).permit(:name, :description, :unit_of_measure_id)
  end
end