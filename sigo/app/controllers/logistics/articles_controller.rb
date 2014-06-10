class Logistics::ArticlesController < ApplicationController
  
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  
  def index
    flash[:error] = nil
    @unitOfMeasurement = UnitOfMeasurement.first
    @group = Category.first
    @company = Company.find(get_company_cost_center("company"))
    @subgroup = Category.where("code LIKE '____'").first
    @typeOfArticle = TypeOfArticle.first
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted' || params[:task] == 'import'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def specifics_articles
    cost_center = CostCenter.find(get_company_cost_center('cost_center'))
    @name = cost_center.name
    render layout: false
  end

  def json_specifics_articles
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    array = Array.new
    articles = Article.getSpecificArticles(get_company_cost_center('cost_center'), display_length, pager_number)

    articles.each do |article|
      array << [article[1],article[2],article[3],article[4],article[5],article[6]]
    end
    render json: { :aaData => array }
  end

  def display_articles
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    array = Array.new
    articles = ActiveRecord::Base.connection.execute("
      SELECT a.id, 
      a.code AS 'Codigo', 
      toa.name AS 'Tipo de Articulo', 
      c.name AS 'Especifico', 
      a.name AS 'Nombre', 
      a.description AS 'Descripcion', 
      uom.name AS 'Unidad de Medida' 
      FROM articles a, type_of_articles toa, categories c, unit_of_measurements uom 
      WHERE a.type_of_article_id = toa.id 
      AND a.category_id = c.id 
      AND uom.id = a.unit_of_measurement_id 
      LIMIT #{display_length}
      OFFSET #{pager_number}"
    )

    articles.each do |article|
      array << [article[1],article[2],article[3],article[4],article[5],article[6], "<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/articles/" + article[0].to_s + "/edit', 'content', null, null, 'GET')> Editar </a>" + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/articles/" + article[0].to_s + "', 'content', '/logistics/articles') data-placement='left' data-popout='true' data-singleton='true' data-title='Esta seguro de eliminar el item" + article[3].to_s + "' data-toggle='confirmation' data-original-title='' title=''> Eliminar </a>"]
    end
    render json: { :aaData => array }
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
    article.category_id = params[:article]['category']
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
      @specific_article = @article.category.id
      # Traemos las SubCategorias
      # Traemos la subcategoria
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
      category_id = 0
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

          codigo_g = codigo_article + codigo_category
          subcategory = Category.new(:code => codigo_g, :name => name)
          subcategory.save

        end
        ## creacion specific
        if codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
          codigo_s = codigo_article + codigo_category + codigo_subcategory
          subcategory = Category.new(:code => codigo_s, :name => name)
          subcategory.save
          category_id = Category.last.id
        elsif codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion != '00' and codigo.length == 8        
          ##### agregando articles
          unidad = UnitOfMeasurement.where("symbol LIKE ?","%#{unidad_symbol}%")
          count_unidad = unidad.count
          if count_unidad != 0
            unidad_last_id = unidad[0].id
          else
            if UnitOfMeasurement.last.present?
              codigo_unidad = (UnitOfMeasurement.last.code.to_i + 1).to_s.rjust(2, '0')
            else
              codigo_unidad = 1.to_s.rjust(2, '0')
            end
            unidad_new = UnitOfMeasurement.new(:symbol => unidad_symbol, :code => codigo_unidad, :name => unidad_symbol)
            code += 1 
            unidad_new.save
            unidad_last = UnitOfMeasurement.last
            unidad_last_id = unidad_last.id            
          end

          if codigo_article.to_i <59
            type = "02"
            type_id = TypeOfArticle.find_by_code(type).id
          end
          if 58 < codigo_article.to_i and codigo_article.to_i < 69
            type="03"
            TypeOfArticle.where("code LIKE ?", type).each do |toa|
              type_id = toa.id
            end
          end
          if codigo_article.to_i==71
            type="01"
            TypeOfArticle.where("code LIKE ?", type).each do |toa|
              type_id = toa.id
            end
          end
          if codigo_article.to_i==73
            type="04"
            TypeOfArticle.where("code LIKE ?", type).each do |toa|
              type_id = toa.id
            end
          end
          if codigo_article.to_i ==72 || codigo_article.to_i > 73
            type="05"
            TypeOfArticle.where("code LIKE ?", type).each do |toa|
              type_id = toa.id
            end
          end

          codigo = type + codigo

          article = Article.new(:code => codigo, :name => name, :unit_of_measurement_id => unidad_last_id, :category_id => category_id, :type_of_article_id=> type_id)
          article.save
        end        
      end
      @temp = matriz_exel
      redirect_to :action => :index, :task => "import"
    else
      render :layout => false
    end
  end

  private
  def article_parameters
    params.require(:article).permit(:code, :name, :description, :category_id, :type_of_article_id, :unit_of_measurement_id)
  end
end