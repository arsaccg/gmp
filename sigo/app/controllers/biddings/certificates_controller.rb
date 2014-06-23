class Biddings::CertificatesController < ApplicationController
  
  def index
  end

  def new
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
    params.require(:professional).permit()
  end
end
