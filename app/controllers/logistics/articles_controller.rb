class Logistics::ArticlesController < ApplicationController
  before_filter :authenticate_user!
  def index
    #@Article = Article.order("id DESC").group("name")
    @Article = Article.order("id DESC")
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def show_article
    @article = Article.find(params[:id])
    render :show, layout: false
  end

  def create
    article = Article.new(article_parameters)
    article.code = params[:extrafield]['first_code'].to_s + params[:article]['code'].to_s
    if article.save
      params[:article_unit_of_measurements]['unit_of_measurement_id'].each.with_index(1) do |unit_id, i|
        article_per_unit = ArticleUnitOfMeasurement.new
        article_per_unit.article_id = article.id
        article_per_unit.unit_of_measurement_id = unit_id
        article_per_unit.code_article_unit = article.code.to_s + UnitOfMeasurement.find(unit_id).code.to_s
        article_per_unit.save
      end
      flash[:notice] = "Se ha creado correctamente la nueva unidad de medida."
      redirect_to :action => :index, :task => 'created'
    else
      flash[:error] = "Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      redirect_to :action => :index, :task => 'failed'
    end
  end

  def edit
    @article = Article.find(params[:id])
    @categories = Category.all
    @unitOfMeasurement = UnitOfMeasurement.all
    @action = 'edit'
    render layout: false
  end

  def show
    @article = Article.find(params[:id])
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
    @categories = Category.all
    @unitOfMeasurement = UnitOfMeasurement.all
    @reg_n = Time.now.to_i
    render layout: false
  end

  def destroy
    article = Article.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el articulo seleccionado."
    redirect_to :action => :index, :task => 'deleted'
  end

  private
  def article_parameters
    params.require(:article).permit(:code, :name, :description)
  end
end