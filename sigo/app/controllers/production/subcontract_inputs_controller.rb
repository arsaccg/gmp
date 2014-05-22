class Production::SubcontractInputsController < ApplicationController
  def index
    @subcontractInputs = SubcontractInput.all
    @article = Article.where("code LIKE ?", "04%").first
    @company = params[:company_id]
    render layout: false
  end

  def new
    @subcontractInput = SubcontractInput.new
    
    @company = params[:company_id]
    render layout: false
  end

  def create
    subcontract = SubcontractInput.new(subcontract_input_parameters)
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
    @sub = Article.where("code LIKE ?", "04%")
    @equip = Article.where("code LIKE ?", "03%")
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

  def get_articles
    @sub = Article.where("code LIKE ?", "04%")
    @equip = Article.where("code LIKE ?", "03%")
    render json: {:sub => @sub, :equip => @equip}
  end

  private
  def subcontract_input_parameters
    params.require(:subcontract_input).permit(:article_id, :price, :type_article)
  end
end
