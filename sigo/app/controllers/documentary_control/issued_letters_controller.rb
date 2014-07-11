class DocumentaryControl::IssuedLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_issu = TypeOfIssuedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @issu = IssuedLetter.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @issu = IssuedLetter.new
    render layout: false
  end

  def create
    flash[:error] = nil
    issu = IssuedLetter.new(issu_parameters)
    issu.cost_center_id = get_company_cost_center('cost_center')
    if issu.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      issu.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @issu = issu
      render :new, layout: false 
    end
  end

  def edit
    @issu = IssuedLetter.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    issu = IssuedLetter.find(params[:id])
    issu.cost_center_id = get_company_cost_center('cost_center')
    if issu.update_attributes(issu_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      issu.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @issu = issu
      render :edit, layout: false
    end
  end

  def destroy
    issu = IssuedLetter.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => issu
  end

  private
  def issu_parameters
    params.require(:issued_letter).permit(:name, :description, :document, {:type_of_issued_letter_ids => []})
  end
end