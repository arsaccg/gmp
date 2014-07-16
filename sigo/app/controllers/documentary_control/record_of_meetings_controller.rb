class DocumentaryControl::RecordOfMeetingsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @type_rec = TypeOfRecordOfMeeting.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  def show
    @rec = RecordOfMeeting.find(params[:id])
    render layout: false
  end

  def new
    @cost_center = get_company_cost_center('cost_center')
    @type_rec = TypeOfRecordOfMeeting.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @rec = RecordOfMeeting.new
    render layout: false
  end

  def create
    flash[:error] = nil
    rec = RecordOfMeeting.new(rec_parameters)
    rec.cost_center_id = get_company_cost_center('cost_center')
    if rec.save
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      rec.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @rec = rec
      render :new, layout: false 
    end
  end

  def edit
    @rec = RecordOfMeeting.find(params[:id])
    @cost_center = get_company_cost_center('cost_center')
    @type_rec = TypeOfRecordOfMeeting.where("cost_center_id = ?", get_company_cost_center('cost_center').to_s)
    @action = 'edit'
    render layout: false
  end

  def update
    rec = RecordOfMeeting.find(params[:id])
    rec.cost_center_id = get_company_cost_center('cost_center')
    if rec.update_attributes(rec_parameters)
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index, company_id: params[:company_id]
    else
      rec.errors.messages.each do |attribute, error|
        flash[:error] =  attribute " " + flash[:error].to_s + error.to_s + "  "
      end
      # Load new()
      @rec = rec
      render :edit, layout: false
    end
  end

  def destroy
    rec = RecordOfMeeting.destroy(params[:id])    
    flash[:notice] = "Se ha eliminado correctamente."
    render :json => rec
  end

  def record_meetings
    word = params[:wordtosearch]
    @rec = RecordOfMeeting.where('name LIKE "%'+word.to_s+'%" OR description LIKE "%'+word.to_s+'%" AND cost_center_id = ?', get_company_cost_center('cost_center').to_s)
    render layout: false
  end

  private
  def rec_parameters
    params.require(:record_of_meeting).permit(:name, :description, :document, :type_of_record_of_meeting_id)
  end
end