class Administration::ProvisionsController < ApplicationController
  def index
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

  def destroy
    render :json => category
  end

  private
  def provisions_parameters
    params.require(:provision).permit(:name)
  end
end
