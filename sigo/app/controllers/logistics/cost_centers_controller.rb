class Logistics::CostCentersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @company = get_company_cost_center('company')
    @comp = params[:company_id]
    #@own_cost_center = current_user.cost_centers
    @costCenters = CostCenter.where("company_id = ?", params[:company_id])
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @comp = params[:company_id]
    @costCenter = CostCenter.new
    @companies = Company.all
    @companyselected = get_company_cost_center('company')
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    @comp = params[:companyID]
    costCenter = CostCenter.new(cost_center_parameters)
    if costCenter.save
      subcontract = Subcontract.create(entity_id: session[:company] , valorization: 'semanal' , terms_of_payment: 'contado' , initial_amortization_number: 0 , initial_amortization_percent: 0 , guarantee_fund: 0 , detraction: 0 , contract_amount: 0 , cost_center_id: session[:cost_center])
      @name = costCenter.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
      wbsitem = Wbsitem.new
      wbsitem.codewbs = costCenter.id
      wbsitem.name = costCenter.name
      wbsitem.cost_center_id = costCenter.id
      if wbsitem.save
        CostCenter.create_table_weeks(costCenter.id)
        CostCenter.create_table_articles(costCenter.id)
        add_weeks_table(costCenter.id,params[:startdate2])
        if current_user.has_role? :director
          ActiveRecord::Base.connection.execute("INSERT INTO cost_centers_users (cost_center_id , user_id) VALUES ("+costCenter.id.to_s+", "+current_user.id.to_s+")")
        end
        flash[:notice] = "Se ha creado correctamente el centro de costo."
        puts "------------------------------"
        puts @comp
        puts "------------------------------"
        redirect_to :action => :index, company_id: @comp
      else
        #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
        wbsitem.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :new, layout: false, company_id: @comp
      end

    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :new, layout: false, company_id: @comp
    end
        
  end

  def edit
    @costCenter = CostCenter.find(params[:id])
    @comp = params[:company_id]
    @companies = Company.all
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])
    @comp = params[:companyID]
    if params[:timeline] == nil
      # Save Maintenance
      if costCenter.update_attributes(cost_center_parameters)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index, company_id: @comp
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false, company_id: @comp
      end
    else
      # Save TimeLine by Start Date / End Date
      if costCenter.update_attributes(cost_center_parameters_timeline)
        CostCenterTimeline.LoadTimeLine(costCenter.id, costCenter.start_date, costCenter.end_date)

        flash[:notice] = "Se actualizo la duracion del proyecto."
        redirect_to :action => :index, company_id: @comp
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false, company_id: @comp
      end
    end
  end

  def destroy
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])
    if costCenter.update_attributes({status: "D"})#, user_updates_id: params[:current_user_id]})
      flash[:notice] = "Se ha eliminado correctamente."
      render :json => {notice: flash[:notice]}
    else
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :json => {error: flash[:error]}
    end
  end

  def save
    if valid?
      #save method implementation
      true
    else
      false
    end
  end

  def add_weeks_table(cost_center_id,start_date)
    @weeknumber = 1
    @count= 1
    @start_date = start_date.to_date
    while @count < 531  do
      @end_date = @start_date + 6.day
      @week = 'Semana ' + @weeknumber.to_s + ' ' + @start_date.year.to_s
      ActiveRecord::Base.connection.execute("
        INSERT INTO weeks_for_cost_center_"+cost_center_id.to_s+"  (name, start_date, end_date)
        VALUES ('"+@week+"', '"+@start_date.to_s+"', '"+@end_date.to_s+"')
        ;")
      if @start_date.year.to_i!=@end_date.year.to_i ||  @weeknumber ==53 || (@end_date.day.to_i==31 && @end_date.month.to_i==12)
        @weeknumber = 1
      else
        @weeknumber +=1
      end
      @start_date = @start_date + 7.day
      @count +=1
    end
  end

  def update_timeline
    @costCenter = CostCenter.find(params[:id])
    @costCenterTimeLine = CostCenterTimeline.where("cost_center_id =" + @costCenter.id.to_s)
    @comp = params[:company_id]
    render(partial: 'form_timeline', :layout => false)
  end

  def select_warehouses
    @select = CostCenter.find(params[:id]).warehouses
    
    render(partial: 'select', :layout => false)
  end


  private


  def cost_center_parameters
    params.require(:cost_center).permit(:code, :name, :company_id)
  end

  def cost_center_parameters_timeline
    params.require(:cost_center).permit(:start_date, :end_date)
  end

end