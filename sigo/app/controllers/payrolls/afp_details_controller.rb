class Payrolls::AfpDetailsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @afp = Afp.where("status = 1")
    render layout: false
  end

  def show
    @afp = Afp.find(params[:id])
    render layout: false
  end

  def new
    @afp = Afp.new 
    @today = Time.now
    render layout: false
  end

  def create
    render :new, layout: false 
  end

  def edit
    @afp = AfpDetail.find(params[:id])
    @today = Time.now
    @action = 'edit'
    render layout: false
  end

  def update
    afp = AfpDetail.find(params[:id])
    if afp.update_attributes(afp_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :show, :controller => :afps, :id=>afp.afp_id
    else
      afp.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @afp = afp
      render :edit, layout: false
    end
  end

  def destroy
    afp = Afp.find(params[:id])
    render :json => afp
  end

  private
  def afp_parameters
    params.require(:afp_detail).permit(:contribution_fp, :insurance_premium, :top, :c_variable, :mixed)
  end
end