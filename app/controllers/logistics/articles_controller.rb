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
    @categories = Category.all
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
    @categories = Category.all
    @unitOfMeasurement = UnitOfMeasurement.all
    render layout: false
  end

  def destroy
    article = Article.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el articulo seleccionado."
    redirect_to :action => :index, :task => 'deleted'
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
    params.require(:article).permit(:code, :name, :description, :unit_of_measurement_id)
  end
end