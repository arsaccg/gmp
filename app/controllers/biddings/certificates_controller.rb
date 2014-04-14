class Biddings::CertificatesController < ApplicationController
  def index
    flash[:error] = nil
    @certificate = Certificate.all
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
    @profesional = Professional.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    @work = Work.all
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

  def delete
    certificate = Certificate.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el certificado seleccionado."
    render :json => certificate
  end

  def get_component_from_work
    @components = Component.where("work_id = ?", params[:work_id])
    render json: {:components => @components}  
  end

  private
  def certificate_parameters
    params.require(:certificate).permit(:professional_id, :work_id, :charge, :contractor, :other, :start_date, :finish_date, {:component_work_id => []}, :certificate)
  end
end
