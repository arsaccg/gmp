class Logistics::PhasesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @phases = Phase.where("category LIKE 'phase'")
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted'
      render layout: 'dashboard'
    else
      render layout: false
    end
  end

  def getSpecificsPhases
    @phases = Phase.getSpecificPhases(get_company_cost_center('cost_center'))
    render :specific_phases, layout: false
  end

  def create
    flash[:error] = nil
    phase = Phase.new(phase_parameters)
    if phase.category == "subphase"
      phase.code = params[:extrafield]['first_code'].to_s + params[:phase]['code'].to_s
    end
    if phase.save
      if phase.category == "subphase"
        flash[:notice] = "Se ha creado correctamente la nueva subfase."
      else
        flash[:notice] = "Se ha creado correctamente la nueva fase."
      end
      redirect_to :action => :index
    else
      phase.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      if phase.category == "subphase"
        @phase = phase
        @phases = Phase.all.where(category: 'phase')
        render :partial => 'addsub', layout: false
      else
        @phase = phase
        render :new, layout: false
      end
    end
  end

  def edit
    @phase = Phase.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def editsub
    @phase = Phase.find(params[:id])
    @phase.category = "subphase"
    @phases = Phase.all.where(category: 'phase')
    render :partial => 'editsub', layout: false
  end

  def show
    #phase = Phase.find(params[:id])
    #render :show
  end

  def update
    phase = Phase.find(params[:id])
    if phase.category == "subphase"
      params[:phase]['code'] = params[:extrafield]['first_code'].to_s + params[:phase]['code'].to_s
    end
    if phase.update_attributes(phase_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      phase.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      if phase.category == "subphase"
        @phase = phase
        @phases = Phase.all.where(category: 'phase')
        render :partial => 'editsub', layout: false
      else
        @phase = phase
        render :new, layout: false
      end
    end
  end

  def new
    @phase = Phase.new
    @phase.category = "phase"
    render layout: false
  end

  def addsub
    @phase = Phase.new
    @phase.category = "subphase"
    @phases = Phase.all.where(category: 'phase')
    render :partial => 'addsub', layout: false
  end

  def destroy
    phase = Phase.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente la fase seleccionado."
    render :json => phase
    #redirect_to :action => :index, :task => 'deleted'
  end

  private
  def phase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
