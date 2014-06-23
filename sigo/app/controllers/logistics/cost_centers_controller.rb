class Logistics::CostCentersController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  
  def index
    flash[:error] = nil
    @company = get_company_cost_center('company')
    #@own_cost_center = current_user.cost_centers
    @costCenters = CostCenter.all
    render layout: false
  end

  def show
    render :json => nil
  end

  def new
    @costCenter = CostCenter.new
    @companies = Company.all
    @companyselected = get_company_cost_center('company')
    render :new, layout: false
  end

  def create
    flash[:error] = nil
    costCenter = CostCenter.new(cost_center_parameters)
    if costCenter.save
      @name = costCenter.name.delete("^a-zA-Z0-9-").gsub("-","_").downcase.tr(' ', '_')
      wbsitem = Wbsitem.new
      wbsitem.codewbs = costCenter.id
      wbsitem.name = costCenter.name
      wbsitem.cost_center_id = costCenter.id
      puts params[:startdate2].inspect
      if wbsitem.save
        ActiveRecord::Base.connection.execute("
          CREATE TABLE weeks_for_cost_center_"+costCenter.id.to_s+" 
            (
              id int NOT NULL AUTO_INCREMENT,
              name varchar(255),
              start_date DATE,
              end_date DATE,
              primary key (id)
          );")
        add_weeks_table(costCenter.id,params[:startdate2])
        ActiveRecord::Base.connection.execute("
          CREATE TABLE articles_from_"+@name+" 
            (
              id int NOT NULL AUTO_INCREMENT,
              article_id int(11),
              code varchar(255),
              type_of_article_id int(11),
              category_id int(11),
              name varchar(255),
              description varchar(255),
              unit_of_measurement_id int(11),
              cost_center_id int(11),
              input_by_budget_and_items_id int(11),
              budget_id int(11),
              primary key (id)
          );")
        flash[:notice] = "Se ha creado correctamente el centro de costo."
        redirect_to :action => :index
      else
        #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
        wbsitem.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :new, layout: false
      end

    else
      #"Ha ocurrido un problema. Porfavor, contactar con el administrador del sistema."
      costCenter.errors.messages.each do |attribute, error|
        flash[:error] =  flash[:error].to_s + error.to_s + "  "
      end
      @costCenter = costCenter
      render :new, layout: false
    end
        
  end

  def edit
    @costCenter = CostCenter.find(params[:id])
    @companies = Company.all
    @action = 'edit'
    render layout: false
  end

  def update
    flash[:error] = nil
    costCenter = CostCenter.find(params[:id])

    if params[:timeline] == nil
      # Save Maintenance
      if costCenter.update_attributes(cost_center_parameters)
        flash[:notice] = "Se ha actualizado correctamente los datos."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
      end
    else
      # Save TimeLine by Start Date / End Date
      if costCenter.update_attributes(cost_center_parameters_timeline)
        CostCenterTimeline.LoadTimeLine(costCenter.id, costCenter.start_date, costCenter.end_date)

        flash[:notice] = "Se actualizó la duración del proyecto."
        redirect_to :action => :index
      else
        costCenter.errors.messages.each do |attribute, error|
          flash[:error] =  flash[:error].to_s + error.to_s + "  "
        end
        @costCenter = costCenter
        render :edit, layout: false
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
    
    render(partial: 'form_timeline', :layout => false)
  end

  def select_warehouses
    @select = CostCenter.find(params[:id]).warehouses
    
    render(partial: 'select', :layout => false)
  end

  private
  def cost_center_parameters
    params.require(:cost_center).permit(:code, :name, :company_id, :overhead_percentage, :igv)
  end

  def cost_center_parameters_timeline
    params.require(:cost_center).permit(:start_date, :end_date)
  end

end