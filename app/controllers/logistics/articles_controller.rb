class Logistics::ArticlesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  
  def index
    flash[:error] = nil
    #@Article = Article.order("id DESC").group("name")
    @Article = Article.order("id DESC")
    @unitOfMeasurement = UnitOfMeasurement.first
    @group = Category.first
    @subgroup = Subcategory.first
    @typeOfArticle = TypeOfArticle.first
    @specific = Specific.first
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
    flash[:error] = nil
    article = Article.new(article_parameters)
    article.code = params[:extrafield]['first_code'].to_s + params[:article]['code'].to_s
    if article.save
      flash[:notice] = "Se ha creado correctamente el articulo."
      redirect_to :action => :index
    else
      article.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    # Todos los tipos de insumos
    @typeOfArticles = TypeOfArticle.all
    # El Insumo
    @article = Article.find(params[:id])
    # El tipo especifico de Insumo
    @typeOfArticle = @article.type_of_article.id
    # Todas las categorias
    @categories = Category.all
    # La categoria al que pertenece
    @specific_article = @article.specific.id
    # Traemos las SubCategorias
    # Traemos la subcategoria
    @subcategory_article = Subcategory.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
    @subcategory_article.each do |sub|
      @subcategory_article = sub.code
    end
    @specific_article = Specific.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
    @specific_article.each do |spe|
      @specific_article = spe.code
    end

    # Traemos las Unidades de Medida
    @unitOfMeasurement = UnitOfMeasurement.all
    @unitid = @article.unit_of_measurement_id
    @action = 'edit'
    render layout: false
  end

  def show
    @article = Article.find(params[:id])
    render :show
  end

  def update
    article = Article.find(params[:id])
    article.code = params[:extrafield]['first_code'].to_s + params[:article]['code'].to_s
    article.name = params[:article]['name']
    article.description = params[:article]['description']
    article.specific_id = params[:article]['specific_id']
    article.type_of_article_id = params[:article]['type_of_article_id']
    article.unit_of_measurement_id = params[:article]['unit_of_measurement_id']
    if article.save
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      article.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @article = article
      # El tipo especifico de Insumo
      @typeOfArticle = @article.type_of_article.id
      @specific = Specific.all
      # La categoria al que pertenece
      @specific_article = @article.specific.id
      # Traemos las SubCategorias
      @subcategories = @article.category.subcategories
      # Traemos la subcategoria
      @subcategory_article = Subcategory.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
      @subcategory_article.each do |sub|
        @subcategory_article = sub.code
      end
      @specific_article = Specific.where("code LIKE ?", "#{@article.code.first(6).from(2)}")
      @specific_article.each do |spe|
        @specific_article = spe.code
      end
      # Traemos las Unidades de Medida
      @units = Array.new
      article.unit_of_measurements.each do |aunit|
        @units << [aunit.id]
      end
      @unitOfMeasurement = UnitOfMeasurement.all
      @typeOfArticles = TypeOfArticle.all
      @reg_n = Time.now.to_i
      render :edit, layout: false
    end
  end

  def new
    @article = Article.new
    @specifics = Specific.all
    @categories = Category.all
    @unitOfMeasurement = UnitOfMeasurement.all
    @typeOfArticles = TypeOfArticle.all
    @reg_n = Time.now.to_i
    render layout: false
  end

  def destroy
    article = Article.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el articulo seleccionado."
    render :json => article
  end

  def import
    if !params[:file].nil?
      s = Roo::Excelx.new(params[:file].path,nil, :ignore)
      matriz_exel = []
      cantidad = s.count.to_i
      (1..cantidad).each do |fila|  
        codigo                        =       "#{s.cell('A',fila)}#{s.cell('B',fila)}#{s.cell('C',fila)}#{s.cell('D',fila)}" 
        codigo_article                =       s.cell('A',fila).to_s  
        codigo_category               =       s.cell('B',fila).to_s
        codigo_subcategory            =       s.cell('C',fila).to_s
        codigo_subcategory_extencion  =       s.cell('D',fila).to_s
        name                          =       s.cell('E',fila).to_s

        ## creacion de articulos
        if codigo_article != "00" and codigo_category == "00" and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          article = Article.new(:code => codigo, :name => name )
          article.save          
        end

        ## creacion de categoria
        if codigo_article != '00' and codigo_category != '00' and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          article_lats = Article.last
          article_lats_id = article_lats.id
          category = Category.new(:code => codigo, :name => name, :article_id => article_lats_id)
          category.save
        end

        ## creacion subcategory
        if codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          category_last = Category.last
          category_last_id = category_last.id
          subcategory = Subcategory.new(:code => codigo, :name => name, :category_id => category_last_id)
          subcategory.save
        elsif codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion != '00' and codigo.length == 8        
          category_last = Category.last
          category_last_id = category_last.id
          subcategory = Subcategory.new(:code => codigo, :name => name, :category_id => category_last_id )
          subcategory.save
        end        
      end
      @temp = matriz_exel
      #s.cell('E',fila)
    end
  end

  private
  def article_parameters
    params.require(:article).permit(:code, :name, :description, :specific_id, :type_of_article_id, :unit_of_measurement_id)
  end
end