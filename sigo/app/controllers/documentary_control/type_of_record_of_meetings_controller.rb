class DocumentaryControl::TypeOfRecordOfMeetingsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    flash[:error] = nil
    @typeOfRem = TypeOfRecordOfMeeting.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def new
    @typeOfRem = TypeOfRecordOfMeeting.new
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    typeOfRem = TypeOfRecordOfMeeting.new(typeOfRem_parameters)
    typeOfRem.cost_center_id = get_company_cost_center('cost_center')
    if typeOfRem.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      typeOfRem.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfRem = typeOfRem
      render :new, layout: false
    end
  end

  def edit
    @typeOfRem = TypeOfRecordOfMeeting.find(params[:id])
    @action = 'edit'
    render layout: false
  end

  def update
    typeOfRem = TypeOfRecordOfMeeting.find(params[:id])
    typeOfRem.cost_center_id = get_company_cost_center('cost_center')
    if typeOfRem.update_attributes(typeOfRem_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
    else
      typeOfRem.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @typeOfRem = typeOfRem
      render :edit, layout: false
    end
  end

  def destroy
    typeOfRem = TypeOfRecordOfMeeting.destroy(params[:id])
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => typeOfRem
  end

  private
  def typeOfRem_parameters
    params.require(:type_of_record_of_meeting).permit(:preffix, :name)
  end
end