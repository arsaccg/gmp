class Biddings::CertificatesController < ApplicationController
  
  def index
  end

  def new
    @pro_id=params[:id]
    @reg = Time.now.to_i
    @certificate = Certificate.new
    @major = Major.all
    @charge = Charge.all
    @entities = Array.new
    TypeEntity.where("id IN (1,5)").each do |tent|
      @entities << tent.entities
    end
    render :new, layout: false
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private
  def certificate_parameters
    params.require(:certificate).permit()
  end
end
