class DocumentaryControl::ReceivedLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_recei = TypeOfReceivedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @recei = ReceivedLetter.find(params[:id])
    render layout: false
  end

  def new
    @type_recei = TypeOfReceivedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @cost_center = get_company_cost_center('cost_center')
    @recei = ReceivedLetter.new
    render layout: false
  end

  def create
    flash[:error] = nil
    recei = ReceivedLetter.new(recei_parameters)
    recei.cost_center_id = get_company_cost_center('cost_center')
    if recei.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      recei.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @recei = recei
      render :new, layout: false 
    end
  end

  def edit
    @recei = ReceivedLetter.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @type_recei = TypeOfReceivedLetter.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    recei = ReceivedLetter.find(params[:id])
    recei.cost_center_id = get_company_cost_center('cost_center')
    if recei.update_attributes(recei_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      recei.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @recei = recei
      render :edit, layout: false
    end
  end

  def destroy
    recei = ReceivedLetter.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => recei
  end

  def received_letters
    word = params[:wordtosearch]
    @recei = ContestDocument.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def recei_parameters
    params.require(:received_letter).permit(:name, :description, :document, :type_of_received_letter_id)
  end
end