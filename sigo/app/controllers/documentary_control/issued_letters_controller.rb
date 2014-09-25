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
    @type_issu = TypeOfIssuedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @issu = IssuedLetter.new
    render layout: false
  end

  def create
    flash[:error] = nil
    issu = IssuedLetter.new(issu_parameters)
    issu.code = issu.code.to_s.rjust(3, '0')
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
    @type_issu = TypeOfIssuedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    issu = IssuedLetter.find(params[:id])
    issu.cost_center_id = get_company_cost_center('cost_center')
    issu.code = issu.code.to_s.rjust(3, '0')
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

  def last_code
    issu = IssuedLetter.where("year LIKE "+params[:year].to_s+" AND cost_center_id = "+get_company_cost_center('cost_center').to_s+" AND type_of_doc LIKE '"+params[:typedoc].to_s+"' AND type_of_issued_letter_id = "+ params[:type].to_s).last
    if issu==nil
      issu = 0.to_s.rjust(3, '0')
    else
      code = issu.code.to_i
      issu = code.to_s.rjust(3, '0')
    end
    render json: {:code => issu} 
  end

  def destroy
    issu = IssuedLetter.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => issu
  end

  def issued_letters
    word = params[:wordtosearch]
    @issu = IssuedLetter.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def issu_parameters
    params.require(:issued_letter).permit(:name, :description, :type_of_doc, :year, :code, :document, :type_of_issued_letter_id, :date)
  end
end