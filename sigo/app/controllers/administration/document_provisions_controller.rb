class Administration::DocumentProvisionsController < ApplicationController
  protect_from_forgery with: :null_session, :only => [:destroy]

  def index
    @documentProvisions = DocumentProvision.all
    render layout: false
  end

  def new
    @documentProvision = DocumentProvision.new
    render :new, layout: false
  end

  def create
    documentProvision = DocumentProvision.new(document_provision_parameters)
    if documentProvision.save
      flash[:notice] = "Se ha creado correctamente la nueva categoria."
      redirect_to :action => :index
    else
      documentProvision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @documentProvision = documentProvision
      render :new, layout: false
    end
  end

  def edit
    @documentProvision = DocumentProvision.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    documentProvision = DocumentProvision.find(params[:id])
    if documentProvision.update_attributes(document_provision_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      documentProvision.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @documentProvision = documentProvision
      render :edit, layout: false
    end
  end

  def destroy
    category = DocumentProvision.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => category
  end

  private
  def document_provision_parameters
    params.require(:document_provision).permit(:name)
  end
end
