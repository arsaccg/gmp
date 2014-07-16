class Administration::ProvisionsController < ApplicationController
  def index
    @provision = Provision.all
    render layout: false
  end

  def new
    @provision = Provision.new
    @suppliers = TypeEntity.find_by_preffix("P").entities
    @cost_center = get_company_cost_center("cost_center")
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
