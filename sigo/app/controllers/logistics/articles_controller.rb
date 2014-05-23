class Logistics::ArticlesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  
  def index
    flash[:error] = nil
    #@Article = Article.order("id DESC").group("name")
    @Article = Article.order("id DESC")
    @unitOfMeasurement = UnitOfMeasurement.first
    @group = Category.first
    @subgroup = Category.where("code LIKE '____'",).first
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
    puts @article.code[2,4]
    # El tipo especifico de Insumo
    @typeOfArticle = @article.type_of_article.id
    # Todas las categorias
    @specifics = Category.where("code LIKE '______'")
    @categories = Category.where("code LIKE '__'")
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
    @specifics = Category.where("code LIKE '______'")
    @categories = Category.where("code LIKE '__'")
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
    @unidades = UnitOfMeasurement.all  
    if !params[:file].nil?
      s = Roo::Excelx.new(params[:file].path,nil, :ignore)
      matriz_exel = []
      code = 1
      cantidad = s.count.to_i
      (1..cantidad).each do |fila|  
        codigo                        =       "#{s.cell('A',fila)}#{s.cell('B',fila)}#{s.cell('C',fila)}#{s.cell('D',fila)}" 
        codigo_article                =       s.cell('A',fila).to_s   # GRUP           --->    GRUPO
        codigo_category               =       s.cell('B',fila).to_s   # SUB            --->    SUBGRUPO
        codigo_subcategory            =       s.cell('C',fila).to_s   # ESPECIFICO 1   --->    ESPECIFIC
        codigo_subcategory_extencion  =       s.cell('D',fila).to_s   # ESPECIFICO 2   --->    ARTICLE

        name                          =       s.cell('E',fila).to_s   
        unidad_symbol                 =       s.cell('F',fila).to_s
        

        ## creacion de Grupos
        if codigo_article != "00" and codigo_category == "00" and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          category = Category.new(:code => codigo_article, :name => name)
          category.save
        end


        ## creacion de Subgrupo
        if codigo_article != '00' and codigo_category != '00' and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8                    

          category_last     =   Category.last
          category_last_id  =   category_last.id
          subcategory       =   Subcategory.new(:code => codigo_category, :name => name, :category_id => category_last_id)
          subcategory.save

        end



        ## creacion subcategory
        if codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          subcategory_last = Subcategory.last
          subcategory_last_id = subcategory_last.id
          specific = Specific.new(:code => codigo_subcategory, :name => name, :subcategory_id => subcategory_last_id)
          specific.save
        elsif codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion != '00' and codigo.length == 8        
          
          specific_last         =     Specific.last
          specific_last_id      =     specific_last.id
          #subcategory_last = Subcategory.last
          #subcategory_last_id = subcategory_last.id



          #specific = Specific.new(:code => codigo_subcategory_extencion, :name => name, :subcategory_id => subcategory_last_id )
          #specific.save

          ##### agregando articles
          unidad = UnitOfMeasurement.where("symbol LIKE ?","%#{unidad_symbol}%")
          count_unidad = unidad.count
          if count_unidad != 0
            unidad_last_id = unidad[0].id
          else
            randon = rand(1000)
            codigo_unidad = "#{code}#{randon}"
            unidad_new = UnitOfMeasurement.new(:symbol => unidad_symbol, :code => codigo_unidad, :name => unidad_symbol)
            code += 1 
            unidad_new.save
            unidad_last = UnitOfMeasurement.last
            unidad_last_id = unidad_last.id            
          end

          article = Article.new(:code => codigo, :name => name, :unit_of_measurement_id => unidad_last_id, :specific_id => specific_last_id)
          article.save
        end        
      end
      @temp = matriz_exel
      redirect_to :action => :index
    end
    render layout: false
  end

  private
  def article_parameters
    params.require(:article).permit(:code, :name, :description, :specific_id, :type_of_article_id, :unit_of_measurement_id)
  end
end