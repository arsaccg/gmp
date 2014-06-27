class Libraries::InterestLinksController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @linkOfIn = InterestLink.all
    render layout: false
  end

  def show
    flash[:error] = nil
    render layout: false
  end

  def new
    @linkOfIn = InterestLink.new
    render layout: false
  end

  def create
    flash[:error] = nil
    linkOfIn = InterestLink.new(links_parameters)
    if linkOfIn.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      linkOfIn.errors.messages.each do |attribute, error|
          puts error.to_s
          puts error
      end
      flash[:error] =  "Ha ocurrido un error en el sistema."
      redirect_to :action => :index
    end
  end

  def edit
    @linkOfIn = InterestLink.find(params[:id])
    render layout: false
  end

  def update
    linkOfIn = InterestLink.find(params[:id])
    if linkOfIn.update_attributes(links_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      linkOfIn.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @linkOfIn = linkOfIn
      render :edit, layout: false
    end
  end

  def destroy
    linkOfIn = InterestLink.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el enlace."
    render :json => linkOfIn
  end

  private
  def links_parameters
    params.require(:interest_link).permit(:name, :description, :url)
  end
end