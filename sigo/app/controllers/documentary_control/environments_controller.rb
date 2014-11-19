class DocumentaryControl::EnvironmentsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @env = Environment.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @env = Environment.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @env = Environment.new
    render layout: false
  end

  def create
    flash[:error] = nil
    env = Environment.new(env_parameters)
    env.cost_center_id = get_company_cost_center('cost_center')
    if env.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      env.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @env = env
      render :new, layout: false 
    end
  end

  def edit
    @env = Environment.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @action = 'edit'
    render layout: false
  end

  def update
    env = Environment.find(params[:id])
    env.cost_center_id = get_company_cost_center('cost_center')
    if env.update_attributes(env_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      env.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @env = env
      render :edit, layout: false
    end
  end

  def destroy
    env = Environment.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => env
  end

  private
  def env_parameters
    params.require(:environment).permit(:name, :description, :document)
  end
end