class Biddings::CertificatesController < ApplicationController
  def index
    flash[:error] = nil
    @certificate = Certificate.all
    @work = Work.all
    @professional = Professional.all
    @charge = Charge.all
    @entity = Entity.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @certificate = Certificate.new
    @professional = Professional.all
    @component = Component.all
    @charge = Charge.all
    @work = Work.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    render layout: false
  end

  def create
    flash[:error] = nil
    certificate = Certificate.new(certificate_parameters)
    if certificate.save
      flash[:notice] = "Se ha creado correctamente el certificado."
      redirect_to :action => :index
    else
      certificate.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @certificate = Certificate.find(params[:id])
    @professional = Professional.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    @work = Work.all
    @component =Component.all
    @action = 'edit'
    render layout: false
  end

  def update
    certificate = Certificate.find(params[:id])
    if certificate.update_attributes(certificate_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      certificate.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @certificate = certificate
      render :edit, layout: false
    end
  end

  def destroy
    certificate = Certificate.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el certificado seleccionado."
    render :json => certificate
  end

  def get_component_from_work
    @work = Work.find(params[:work_id])
    @components=@work.components
    render json: {:component_work => @components}  
  end

  def dates_from_work
    @work = Work.find(params[:work_id])
    @start = @work.start_date_of_work
    @finish = @work.real_end_date_of_work
    render json: {:start=>@start, :finish=>@finish}  
  end

  private
  def certificate_parameters
    params.require(:certificate).permit(:professional_id, :work_id, :charge_id, :entity_id, :num_days, :start_date, :finish_date, {:component_work_ids => []}, :certificate, :other)
  end

  private
  def certificate_parameters_other_work
    params.require(:certificate).permit(:other_work, :start, :end, {:component_work_ids => []})
  end
end
