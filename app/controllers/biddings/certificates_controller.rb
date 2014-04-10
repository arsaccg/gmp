class Biddings::CertificatesController < ApplicationController
  def index
    render layout: false
  end

  def show
    render layout: false
  end

  def new
    render layout: false
  end

  def create
    redirect_to :action => :index
  end

  def edit
    render layout: false
  end

  def update
    redirect_to :action => :index
  end

  def delete
  end
end
