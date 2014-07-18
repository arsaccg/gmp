class Administration::SubDailiesController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy]
  def index
    @subDailies = SubDaily.all
    render layout: false
  end

  def new
    @subDaily = SubDaily.new
    render :new, layout: false
  end

  def create
    subDaily = SubDaily.new(sub_daily_parameters)
    if subDaily.save
      flash[:notice] = "Se ha creado correctamente el nuevo Sub-Diario."
      redirect_to :action => :index
    else
      subDaily.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @subDaily = subDaily
      render :new, layout: false
    end
  end

  def edit
    @subDaily = SubDaily.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    subDaily = SubDaily.find(params[:id])
    if subDaily.update_attributes(sub_daily_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      subDaily.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @subDaily = subDaily
      render :edit, layout: false
    end
  end

  def destroy
    subDaily = SubDaily.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => subDaily
  end

  def import
    render layout: false
  end

  def do_import
    sub_dailies_buffer = Array.new
    if !params[:file].nil?
      s = Roo::Excelx.new(params[:file].path,nil, :ignore)
      cantidad = s.count.to_i
      (1..cantidad).each do |fila|  
        codigo                =       s.cell('A',fila).to_s
        name               =       s.cell('B',fila).to_s

        if codigo.to_s != ''
          sub_dailies_buffer << SubDaily.new(:code => codigo, :name => name)
        end        
      end
      SubDaily.import sub_dailies_buffer
      redirect_to :action => :index
    else
      render :layout => false
    end
  end

  private
  def sub_daily_parameters
    params.require(:sub_daily).permit!
  end
end
