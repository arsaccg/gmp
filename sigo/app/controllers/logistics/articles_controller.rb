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
    @cost_center = CostCenter.find(get_company_cost_center('cost_center')) rescue nil
    if !@cost_center.nil?
      Budget.where("type_of_budget = 0 AND cost_center_id = ?", @cost_center.id).each do |budget|
        @budget = budget
      end
    end

    render layout: false
  end

  def new_specific
    @specifics = Category.where("code LIKE '______'")
    @categories = Category.where("code LIKE '__'")
    @unitOfMeasurement = UnitOfMeasurement.all
    @typeOfArticles = TypeOfArticle.all
    @reg_n = Time.now.to_i
    render layout: false
  end

  def display_articles_specific
    word = params[:q]
    article_hash = Array.new
    articles = Article.getArticles(word)
    articles.each do |art|
      article_hash << {'id' => art[0].to_s+'-'+art[3].to_s, 'code' => art[1], 'name' => art[2], 'symbol' => art[4]}
    end
    render json: {:articles => article_hash}
  end

  def create_specific
    if params[:article]!= nil
      @name = get_company_cost_center('cost_center')
      data_article_unit = params[:article].to_s.split('-')
      flag=ActiveRecord::Base.connection.execute("
          SELECT DISTINCT a.*
          FROM articles_from_cost_center_" + @name.to_s + " a
          WHERE a.id = "+data_article_unit[0]+"
        ")
      if flag != nil
        @article = Article.find(data_article_unit[0])
        ActiveRecord::Base.connection.execute("
          INSERT INTO articles_from_cost_center_" + @name.to_s + " (article_id, code, type_of_article_id, category_id, name, description, unit_of_measurement_id, cost_center_id)
          VALUES ("""+@article.id.to_i.to_s+",'"+@article.code.to_s+"',"+@article.type_of_article_id.to_i.to_s+","+@article.category_id.to_i.to_s+",'"+@article.name.to_s+"','"+@article.description.to_s+"',"+@article.unit_of_measurement_id.to_i.to_s+","+@cost_center.id.to_i.to_s+""")
        ")
        flash[:notice] = "Se ha creado correctamente el articulo."
        redirect_to :action => :specifics_articles  
      else
        render :new_specific, layout: false
      end
    else
      render :new_specific, layout: false
    end
  end

  def edit_specific
    @id=params[:id]
    @name = get_company_cost_center('cost_center')
    arsm=ActiveRecord::Base.connection.execute("
          SELECT DISTINCT a.*
          FROM articles_from_cost_center_" + @name.to_s + " a
          WHERE a.id = " + @id + "
        ")
    arsm.each do |my|
      @ars=my
    end
    @id = @ars[0]
    @art_id = @ars[1]
    @type = @ars[3]
    @unit = @ars[7] 
    @code = @ars[2]
    @category = @ars[4]
    @desc = @ars[6]
    @name = @ars[5]
    @specifics = Category.where("code LIKE '______'")
    @categories = Category.where("code LIKE '__'")
    @unitOfMeasurement = UnitOfMeasurement.all
    @typeOfArticles = TypeOfArticle.all
    render layout: false
  end

  def update_specific
    @name = get_company_cost_center('cost_center')
    @id = params[:articles]['id'].to_i.to_s
    @artid = params[:articles]['article_id'].to_i.to_s
    @code = params[:extrafield]['first_code'].to_s + params[:articles]['code'].to_s
    @artty = params[:article]['type_of_article_id'].to_i.to_s
    @artcat = params[:article]['category_id'].to_i.to_s
    @artname = params[:articles]['name'].to_s
    @artdesc = params[:articles]['description'].to_s
    @artunit = params[:article]['unit_of_measurement_id'].to_i.to_s
    if @id!=nil && @artid !=nil && @code !=nil && @artty !=nil && @artcat !=nil && @artname !=nil && @artdesc !=nil && @artunit
      ActiveRecord::Base.connection.execute("
        UPDATE articles_from_cost_center_" + @name.to_s + " SET
        article_id = "+@artid+",
        code = '"+@code+"',
        type_of_article_id = "+@artty+",
        category_id = "+@artcat+",
        name = '"+@artname+"', 
        description = '"+@artdesc+"',
        unit_of_measurement_id = "+@artunit+",
        cost_center_id = "+@cost_center.id.to_i.to_s+"
        WHERE id = "+@id+"
      ")
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :specifics_articles
    else
      render :edit_specific, layout: false
    end
    
  end

  def delete_specific
    id = params[:id]
    @name = get_company_cost_center('cost_center')
    article = ActiveRecord::Base.connection.execute("
      DELETE FROM articles_from_cost_center_" + @name.to_s + " WHERE id = " + id + "
    ")
    flash[:notice] = "Se ha eliminado correctamente el articulo seleccionado."
    render :json => article
  end

  # METHODS DataTables

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

  def json_articles_from_specific_article_table
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    array = Array.new
    articles = Article.find_articles_in_specific_table(get_company_cost_center('cost_center'), display_length, pager_number)
    articles.each do |article|
      array << [article[1],article[2],article[3],article[4],article[5],"<a class='btn btn-warning btn-xs' onclick=javascript:load_url_ajax('/logistics/articles/" + article[0].to_s + "/edit_specific', 'content', null, null, 'GET')>Editar</a>"]
    end
    render json: { :aaData => array }
  end

  def display_articles
    display_length = params[:iDisplayLength]
    pager_number = params[:iDisplayStart]
    @pagenumber = params[:iDisplayStart]
    array = Array.new
    if @pagenumber == 'NaN'
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
        ORDER BY a.id DESC
        LIMIT #{display_length}"
      )
    else
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
    end
    articles.each do |article|
      array << [article[1],article[2],article[3],article[4],article[5],article[6], "<a class='btn btn-warning btn-xs' onclick = javascript:load_url_ajax('/logistics/articles/"+article[0].to_s+"/edit','content',null,null,'GET')> Editar </a>" + "<a class='btn btn-danger btn-xs' data-onclick=javascript:delete_to_url('/logistics/articles/"+article[0].to_s+"','content','/logistics/articles') data-placement='left' data-popout='true' data-singleton='true' data-toggle='confirmation' data-title='Esta seguro de eliminar el item " + article[4].to_s + "'  data-original-title='' title=''> Eliminar </a>"]
    end
    render json: { :aaData => array }
  end

  # END METHODS DataTables

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
      @log = Array.new
      (1..cantidad).each do |fila|  
        codigo                        =       "#{s.cell('A',fila).to_s.to(1)}#{s.cell('B',fila).to_s.to(1)}#{s.cell('C',fila).to_s.to(1)}#{s.cell('D',fila).to_s.to(1)}" 
        codigo_article                =       s.cell('A',fila).to_s.to(1)   # GRUP           --->    GRUPO
        codigo_category               =       s.cell('B',fila).to_s.to(1)   # SUB            --->    SUBGRUPO
        codigo_subcategory            =       s.cell('C',fila).to_s.to(1)   # ESPECIFICO 1   --->    ESPECIFIC
        codigo_subcategory_extencion  =       s.cell('D',fila).to_s.to(1)   # ESPECIFICO 2   --->    ARTICLE

        name                          =       s.cell('E',fila).to_s   
        unidad_symbol                 =       s.cell('F',fila).to_s
        
        if codigo.to_i != 0
          ## creacion de Grupos
          if codigo_article != "00" and codigo_category == "00" and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
            category = Category.new(:code => codigo_article, :name => name)
            category.save
            if !category.save
              @log << fila
            end
          end
          ## creacion de Subgrupo
          if codigo_article != '00' and codigo_category != '00' and codigo_subcategory == '00' and codigo_subcategory_extencion == '00' and codigo.length == 8                    
            codigo_g = codigo_article + codigo_category
            subcategory = Category.new(:code => codigo_g, :name => name)
            subcategory.save
            if !subcategory.save
              @log << fila
            end
          end
          ## creacion specific
          if codigo_article != '00' and codigo_category != '00' and codigo_subcategory != '00' and codigo_subcategory_extencion == '00' and codigo.length == 8
            codigo_s = codigo_article + codigo_category + codigo_subcategory
            subcategory = Category.new(:code => codigo_s, :name => name)
            subcategory.save
            if !subcategory.save
              @log << fila
            end
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

            if !article.save
              @log <<fila
            end
          end
        end        
      end
      @temp = matriz_exel
      puts "------------------------------------------------------------------------------------------------------------------"
      @log.each do |log|
        puts log
      end
      puts "------------------------------------------------------------------------------------------------------------------"
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