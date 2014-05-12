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
    @cont =1 
    @cont2 =1 
    @work = Work.all
    @other= OtherWork.all
    @flag=false
    @charge = Charge.all
    @professional= Professional.find(params[:id])
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entity = tent.entities
    end
    render layout: false
  end

  def new
    @reg = Time.now.to_i
    @professional=Professional.new
    @work = Work.all
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
    @component = Component.all
    @work = Work.all
    @charge = Charge.all
    @entities =Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    @other= OtherWork.all
    @reg = Time.now.to_i
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
    pro = Professional.find(params[:id])
    pro.certificates.each do |cert|
      certificate = Certificate.destroy(cert.id)  
    end
    pro.trainings.each do |tra|
      training = Training.destroy(tra.id)
    end
    profesional = Professional.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => profesional
  end

  def get_component_from_work
    @work = Work.find(params[:work_id])
    @components=@work.components
    @work = Work.find(params[:work_id])
    @start = @work.start_date_of_work
    @finish = @work.real_end_date_of_work
    @entity = @work.entity.name
    contr = Entity.find(@work.contractor_id)
    @contractor = contr.name
    render json: {:start=>@start, :finish=>@finish, :entity=>@entity, :contractor=>@contractor, :component_work => @components}  
  end

  def more_dates
    @reg = Time.now.to_i
    render layout: false
  end

  def more_certificates
    @reg = Time.now.to_i
    @reg2 = Time.now.to_i.to_s
    @work = Work.all
    @major = Major.all
    @component = Component.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    render layout: false
  end
  
  def more_trainings
    @reg = Time.now.to_i
    render layout: false
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
        :num_days, 
        :start_date, 
        :finish_date, 
        :certificate, 
        :other, 
        :_destroy,
        other_work_attributes: [
          :id,
          :certificate_id,
          :name,
          :start,
          :entity,
          :contractor,
          :end,
          :specialty,
          {:component_work_ids => []}, 
          :_destroy
        ]
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