class Administration::ContractTypesController < ApplicationController
	before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @contracttype = ContractType.all
    @company = session[:company]
    render layout: false
  end

  def show
    @contracttype = ContractType.find(params[:id])
    render layout: false
  end

  def new
    @contracttype = ContractType.new 
    @today = Time.now
    render layout: false
  end

  def create
    flash[:error] = nil
    contracttype = ContractType.new(contracttype_parameters)
    if contracttype.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      contracttype.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @contracttype = contracttype
      render :new, layout: false 
    end
  end

  def edit
    @contracttype = ContractType.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    contracttype = ContractType.find(params[:id])
    if contracttype.update_attributes(contracttype_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      contracttype.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @contracttype = contracttype
      render :edit, layout: false
    end
  end

  def destroy
    contracttype = ContractType.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el centro de salud seleccionado."
    render :json => contracttype
  end

  private
  def contracttype_parameters
    params.require(:contract_type).permit(:description, :shortdescription)
  end
end
