class Logistics::TypeOfArticlesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfArticles = TypeOfArticle.all
    render layout: false
  end

  def new
    @typeOfArticle = TypeOfArticle.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfArticle = TypeOfArticle.new(type_of_article_parameters)
    if typeOfArticle.save
      flash[:notice] = "Se ha creado correctamente el tipo de insumo."
      redirect_to :action => :index
    else
      typeOfArticle.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfArticle = typeOfArticle
      render :new, layout: false
    end
  end

  def edit
    @typeOfArticle = TypeOfArticle.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfArticle = TypeOfArticle.find(params[:id])
    if typeOfArticle.update_attributes(type_of_article_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfArticle.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfArticle = typeOfArticle
      render :edit, layout: false
    end
  end

  def destroy
    typeOfArticle = TypeOfArticle.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfArticle
  end

  private
  def type_of_article_parameters
    params.require(:type_of_article).permit(:code, :name)
  end
end