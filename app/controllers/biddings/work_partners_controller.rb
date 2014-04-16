class Biddings::WorkPartnersController < ApplicationController
  def index
    @workPartners = WorkPartner.all
    render layout: false  
  end

  def show
    @workPartners = WorkPartner.find(params[:id])
    render layout: false
  end

  def new
    @workPartner = WorkPartner.new
    render layout: false
  end

  def create
    workPartner = WorkPartner.new(work_partner_params)
    if workPartner.save
      flash[:notice] = "Se ha creado correctamente el Socio."
      redirect_to :action => :index
    else
      workPartner.errors.messages.each do |attribute, error|
        puts error.to_s
        puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @workPartners = WorkPartner.find(params[:id])
    render layout: false
  end

  def update
    workPartner = WorkPartner.find(params[:id])
    if workPartner.update_attributes(work_partner_params)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      workPartner.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @workPartner = workPartner
      render :edit, layout: false
    end
  end

  def destroy
    redirect_to :action => :index
  end

  private
  def work_partner_params
    params.require(:work_partner).permit(:name)
  end
end
