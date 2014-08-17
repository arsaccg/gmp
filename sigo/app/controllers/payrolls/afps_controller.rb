class Payrolls::AfpsController < ApplicationController
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
    flash[:error] = nil
    afp = Afp.new(afp_parameters)
    afp.status = 1
    if afp.save
      ActiveRecord::Base.connection.execute("
        INSERT INTO afp_details (afp_id, contribution_fp, insurance_premium, top, c_variable, mixed, date_entry, status) VALUES ("+afp.id.to_i.to_s+", "+afp.contribution_fp.to_f.to_s+", "+afp.insurance_premium.to_f.to_s+", "+afp.top.to_f.to_s+", "+afp.c_variable.to_f.to_s+", "+afp.mixed.to_f.to_s+",'"+Time.now.strftime("%Y/%m/%d").to_s+"', 1)
        
      ") 
      flash[:notice] = "Se ha creado correctamente."
      redirect_to :action => :index
    else
      afp.errors.messages.each do |attribute, error|
        puts flash[:error].to_s + error.to_s + "  "
      end
      @afp = afp
      render :new, layout: false 
    end
  end

  def edit
    @afp = Afp.find(params[:id])
    @today = Time.now
    @action = 'edit'
    render layout: false
  end

  def update
    afp = Afp.find(params[:id])
    if afp.update_attributes(afp_parameters)
      AfpDetail.where("afp_id LIKE '"+afp.id.to_s+"' AND status = 1").each do |a0|
        ActiveRecord::Base.connection.execute("
          UPDATE afp_details SET
          status = 0
          WHERE id = "+a0.id.to_s+"
        ")
      end
      ActiveRecord::Base.connection.execute("
        INSERT INTO afp_details (afp_id, contribution_fp, insurance_premium, top, c_variable, mixed, date_entry, status) VALUES ("+afp.id.to_i.to_s+", "+afp.contribution_fp.to_f.to_s+", "+afp.insurance_premium.to_f.to_s+", "+afp.top.to_f.to_s+", "+afp.c_variable.to_f.to_s+", "+afp.mixed.to_f.to_s+",'"+Time.now.strftime("%Y/%m/%d").to_s+"', 1)
      ") 
      flash[:notice] = "Se ha actualizado correctamente los datos."
      redirect_to :action => :index
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
    ActiveRecord::Base.connection.execute("
          UPDATE afps SET
          status = 0
          WHERE id = "+afp.id.to_s+"
        ")
    ActiveRecord::Base.connection.execute("
          UPDATE afp_details SET
          status = 0
          WHERE id = "+a0.id.to_s+" AND status = 1
        ")
    render :json => afp
  end

  private
  def afp_parameters
    params.require(:afp).permit(:type_of_afp, :enterprise, :contribution_fp, :insurance_premium, :top, :c_variable, :mixed)
  end
end