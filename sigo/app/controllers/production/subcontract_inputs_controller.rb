class Production::SubcontractInputsController < ApplicationController
  def index
    @company = get_company_cost_center('company')
    cost_center = get_company_cost_center('cost_center')
    @subcontractInputs = SubcontractInput.where("cost_center_id = ?", cost_center)
    @article = Article.where("code LIKE ?", "04%").first
    render layout: false
  end

  def new
    @subcontractInput = SubcontractInput.new
    @company = params[:company_id]
    render layout: false
  end

  def display_articles
    word = params[:q]
    code = params[:code]
    article_hash = Array.new
    articles = ActiveRecord::Base.connection.execute("SELECT id, name FROM articles WHERE code LIKE '#{code}%' AND name LIKE '#{word}%'")
    articles.each do |art|
      article_hash << {'id' => art[0], 'name' => art[1]}
    end
    render json: {:articles => article_hash}  
  end

  def create
    subcontract = SubcontractInput.new(subcontract_input_parameters)
    subcontract.cost_center_id = get_company_cost_center('cost_center')
    if subcontract.save
      flash[:notice] = "Se ha creado correctamente el trabajador."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index, company_id: params[:company_id]
    end
  end

  def edit
    @action = 'edit'
    @subcontractInput = SubcontractInput.find(params[:id])
    if @subcontractInput.type_article == '04'
      @articles = Article.where("code LIKE ?", "04%")
    elsif @subcontractInput.type_article == '03'
      @articles = Article.where("code LIKE ?", "03%")
    end
    @company = params[:company_id]
    render layout: false
  end

  def update
    subcontract = SubcontractInput.find(params[:id])
    if subcontract.update_attributes(subcontract_input_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      subcontract.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @subcontract = subcontract
      render :edit, layout: false
    end
  end

  def destroy
    subcontract = SubcontractInput.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el Detalle del Insumo."
    render :json => subcontract
  end

  private
  def subcontract_input_parameters
    params.require(:subcontract_input).permit(:article_id, :price, :type_article)
  end
end
