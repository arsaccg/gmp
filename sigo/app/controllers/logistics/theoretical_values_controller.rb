class Logistics::TheoreticalValuesController < ApplicationController
	before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @theoretical_values = Article.where("code LIKE '03%'")
    @company = session[:company]
    render layout: false
  end

  def create
    flash[:error] = nil
    theoretical_value = TheoreticalValue.new(theoretical_value_parameters)
    if theoretical_value.save
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      theoretical_value.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      redirect_to :action => :index
    else
      theoretical_value.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @theoretical_value = theoretical_value
      render :new, layout: false
    end

  end

  def edit
    @theoretical_value = TheoreticalValue.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def show
    flash[:error] = nil
    @theoretical_value = TheoreticalValue.find(params[:id])
    render :show
  end

  def update
    flash[:error] = nil
    theoretical_value = TheoreticalValue.find(params[:id])
    if theoretical_value.update_attributes(theoretical_value_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      theoretical_value.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @theoretical_value = theoretical_value
      render :edit, layout: false
    end
  end

  def new
    @theoretical_value = TheoreticalValue.new
    @articles = Article.find(params[:id])
    render :new, layout: false
  end

  def destroy
    theoretical_value = TheoreticalValue.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente el banco seleccionado."
    render :json => theoretical_value
  end

  private
  def theoretical_value_parameters
    params.require(:theoretical_value).permit(:article_id, :theoretical_value)
  end
end
