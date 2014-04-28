class Biddings::ProfessionalsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @professionals = Professional.all
    @major = Major.all
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    @reg = Time.now.to_i.to_s
    @professional=Professional.new
    @major = Major.all
    @component = Component.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end

    render :new, layout: false
  end

  def create
    flash[:error] = nil
    professional = Professional.new(professional_parameters)
    if professional.save
      flash[:notice] = "Se ha creado correctamente al profesional."
      redirect_to :action => :index
    else
      professional.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @professional = professional
      render :new, layout: false
    end
    
  end

  def edit
    @professional = Professional.find(params[:id])
    @work = Work.all
    @reg = Time.now.to_i.to_s
    @major = Major.all
    @action = 'edit'
    render layout: false
  end

  def update
    profesional = Professional.find(params[:id])
    if profesional.update_attributes(professional_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      profesional.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @profesional = profesional
      render :edit, layout: false
    end
  end

  def destroy
    profesional = Professional.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => profesional
  end

  private
  def professional_parameters
    params.require(:professional).permit(
      :name,
      :dni, 
      :professional_title_date, 
      {:major_ids => []}, 
      :date_of_tuition, 
      :code_tuition, 
      :professional_title, 
      :tuition, 
      :cv, 
      certificates_attributes: [
        :id, 
        :professional_id, 
        :work_id, 
        :charge_id, 
        :entity_id, 
        :num_days, 
        :start_date, 
        :finish_date, 
        {:component_work_ids => []}, 
        :certificate, 
        :other, 
        :_destroy
      ], 
      trainings_attributes: [
        :id, 
        :professional_id, 
        :type_training, 
        :name_training,
        :num_hours, 
        :start_training, 
        :finish_training, 
        :training, 
        :_destroy
      ]
    )
  end
end


#-class Biddings::CertificatesController < ApplicationController

#-  def new
#    @certificate = Certificate.new
 #   @professional = Professional.all
  #  @component = Component.all
   # @charge = Charge.all
    #@work = Work.all
   # @entities = Array.new
  # TypeEntity.where("id IN (1,5)").each do |tent|
  #    @entities << tent.entities
  #  end
  #  render layout: false
  #end

  #def create
  #  flash[:error] = nil
  #  certificate = Certificate.new(certificate_parameters)
  #  if certificate.save
  #    flash[:notice] = "Se ha creado correctamente el certificado."
  #    redirect_to :action => :index
  #  else
  #    certificate.errors.messages.each do |attribute, error|
  #      puts error.to_s
   #     puts error
   #   end
   #   flash[:error] =  "Ha ocurrido un error en el sistema."
   #   redirect_to :action => :index
   # end
  #end

  #def edit
    #@certificate = Certificate.find(params[:id])
    #@professional = Professional.all
    #@charge = Charge.all
   # @entities = Array.new
  #  TypeEntity.where("id IN (1,5)").each do |tent|
 #     @entities << tent.entities
#    end
   # @work = Work.all
   # @component =Component.all
  #  @action = 'edit'
 #   render layout: false
#  end

#  def update
#    certificate = Certificate.find(params[:id])
#    if certificate.update_attributes(certificate_parameters)
#      flash[:notice] = "Se ha actualizado correctamente los datos."
#      redirect_to :action => :index
#    else
#      certificate.errors.messages.each do |attribute, error|
#        flash[:error] =  flash[:error].to_s + error.to_s + "  "
#      end
#-      # Load new()
#-      @certificate = certificate
#-      render :edit, layout: false
#   end
#-  end
#-
#  def destroy
#-    certificate = Certificate.destroy(params[:id])
#-    flash[:notice] = "Se ha eliminado correctamente el certificado seleccionado."
#-    render :json => certificate
#-  end
#-
#  def get_component_from_work
#-    @work = Work.find(params[:work_id])
#-    @components=@work.components
#-    render json: {:component_work => @components}  
#-  end
#-
#-  def dates_from_work
#-    @work = Work.find(params[:work_id])
#-    @start = @work.start_date_of_work
#-    @finish = @work.real_end_date_of_work
#-    render json: {:start=>@start, :finish=>@finish}  
#-  end
 #-    params.require(:certificate).permit(:other_work, :start, :end, {:component_work_ids => []})
 #-  end
 #-end
