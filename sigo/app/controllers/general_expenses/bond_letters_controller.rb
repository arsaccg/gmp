class GeneralExpenses::BondLettersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @letters = BondLetter.where("cost_center_id = "+params[:cc].to_s)
    @cc = CostCenter.find(params[:cc])
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @cc = CostCenter.find(params[:cc])
    @letters = BondLetter.new
    @issuer = TypeEntity.find_by_preffix("P").entities
    @receptor = TypeEntity.find_by_preffix("C").entities
    @receptor = @receptor + @issuer
    render layout: false  
  end

  def new_bond_letter_detail
    @cc = CostCenter.find(params[:cc])
    @bl = params[:bl]
    @letter_detail = BondLetterDetail.new()
    render layout: false
  end

  def create
    flash[:error] = nil
    letter = BondLetter.new(letter_params)
    if letter.save
      letter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render :json => letter
  end

  def create_bond_letter_detail
    flash[:error] = nil
    letter = BondLetterDetail.new(letter_details_params)
    if letter.save
      letter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
    end
    render :json => letter
  end  

  def edit
    @cc = CostCenter.find(params[:cc])
    @letter = BondLetter.find(params[:id])
    @action = 'edit'
    @issuer = TypeEntity.find_by_preffix("P").entities
    @receptor = TypeEntity.find_by_preffix("C").entities
    @receptor = @receptor + @issuer    
    render layout: false    
  end

  def edit_bond_letter_detail
    @cc = CostCenter.find(params[:cc])
    @letter_detail = BondLetterDetail.find(params[:id])
    @action = 'edit'
    @bl = params[:bl]
    render layout: false    
  end  

  def update
    letter = BondLetter.find(params[:id])
    if letter.update_attributes(letter_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :controller => "bond_letter", :cc => letter.cost_center_id
    else
      con.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @letter = letter
      render :edit, layout: false, :cc => letter.cost_center_id
    end    
  end

  def destroy
    loan = BondLetter.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => loan
  end

  def show_summary_table
    @cc = CostCenter.find(params[:cc])
    @letter = BondLetter.find(params[:id])
    render(:partial => 'table_deliveries', :layout => false)
  end  

  def type_advances
    @advances = Advance.where(cost_center_id: params[:cost_center])
    render json: {:advances => @advances}
  end

  private
  def letter_params
    params.require(:bond_letter).permit(:cost_center_id, :issuer_entity_id, :receptor_entity_id, :advance_id, :status, :concept)
  end
  def letter_details_params
    params.require(:bond_letter_detail).permit(:bond_letter_id, :code, :issu_date, :expiration_date, :amount, :issuance_cost, :retention, :rate)
  end    
end