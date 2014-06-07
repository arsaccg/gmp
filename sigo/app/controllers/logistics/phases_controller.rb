class Logistics::PhasesController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @company = Company.find(get_company_cost_center("company"))
    @phases = Phase.where("category LIKE 'phase'")
    puts Phase.all.count
    cad = "hola"
    puts "cad:"
    puts cad.to_i
    if params[:task] == 'created' || params[:task] == 'edited' || params[:task] == 'failed' || params[:task] == 'deleted' || params[:task] == 'import'
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

  def import    
    if !params[:file].nil?
      s = Roo::Excelx.new(params[:file].path,nil, :ignore)
      matriz_exel = []
      code = 1
      cantidad = s.count.to_i
      puts "------cantidad----------------------------"
      puts cantidad
      (1..cantidad).each do |fila|
        puts "-------------fila---------------------"
        puts fila  
        codigo             =       "#{s.cell('A',fila).to_s.to(1)}#{s.cell('B',fila).to_s.to(1)}"
        puts "-----------codigo-----------------------"
        puts codigo
        codigo_phase       =       s.cell('A',fila).to_s.to(1)   # PH           --->    PHASE
        puts "----------codigo_phase------------------------"
        puts codigo_phase
        codigo_subphase    =       s.cell('B',fila).to_s.to(1)   # SPH          --->    SUBPHASE
        puts "----------codigo_subphase------------------------"
        puts codigo_subphase
        name               =       s.cell('C',fila).to_s 
        puts "----------------name------------------"
        puts name
        ## creacion de PHases
        if codigo.to_i != 0
          if codigo_phase != "00" and codigo_subphase == "00" and codigo.length == 4
            category = Phase.new(:code => codigo_phase, :name => name, :category => "phase")
            category.save
          end
          ## creacion de Subphases
          if codigo_phase != "00" and codigo_subphase != "00" and codigo.length == 4
            codigo = codigo_phase + codigo_subphase
            category = Phase.new(:code => codigo, :name => name, :category => "subphase")
            category.save
          end
        end
        
      end
      redirect_to url_for(:controller => :phases, :action => :index, :task => "import")
    else
      render :layout => false
    end
  end

  private
  def phase_parameters
    params.require(:phase).permit(:code, :name, :category)
  end
end
