class Biddings::OtherWorksController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @pro_id = params[:pro_id]
    other = OtherWork.all
    @ids = Array.new
    other.each do |dos|
      @ids << dos.certificate_id
    end
    @ids = @ids.join(",")
    @certificates = Certificate.where('professional_id = ? AND id IN ('+@ids+')', @pro_id)
    render layout: false
  end

  def show
    @pro_id = params[:pro_id]
    @other = OtherWork.find_by_certificate_id(params[:id])
    @cert = Certificate.find(params[:id])
    @charge = Charge.all
    render layout: false
  end


  def new
    @pro_id = params[:pro_id]
    @reg = Time.now.to_i
    @other_work = OtherWork.new
    @major = Major.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    other = OtherWork.new(other_works_parameters)
    if other.save
      flash[:notice] = "Se ha creado correctamente al certificado."
      redirect_to :action => :index, :pro_id=>other.certificate.professional_id
    else
      other.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @other_work = other
      render :new, layout: false
    end
  end

  def edit
    @pro_id = params[:pro_id]
    @other_work = OtherWork.find_by_certificate_id(params[:id])
    @cert = Certificate.find(params[:id])
    @charge = Charge.all
    @action = "edit"
    render :edit, layout: false
  end

  def update
    work = OtherWork.find(params[:id])
    if work.update_attributes(other_works_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, :pro_id=>work.certificate.professional_id
    else
      work.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @work = work
      render :edit, layout: false
    end
  end

  def destroy
    pro = OtherWork.find_by_certificate_id(params[:id])
    certificate = Certificate.destroy(params[:id])
    other_work = OtherWork.destroy(pro.id)
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => other_work
  end

  private
  def other_works_parameters
    params.require(:other_work).permit(
      :name,
      :start,
      :entity,
      :contractor,
      :end,
      :specialty,
      :certificate_id,
      {:component_ids => []},
      certificate_attributes:[
        :id, 
        :professional_id, 
        :other_work_id,
        :work_id, 
        :charge_id, 
        :num_days, 
        :start_date, 
        :finish_date, 
        :certificate, 
        :other, 
        :_destroy
      ])
  end
end