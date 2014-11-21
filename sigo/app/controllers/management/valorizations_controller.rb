class Management::ValorizationsController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update, :newvalorization, :changevalorization, :finalize, :show_data, :change_data_ge, :change_data_u, :change_data_r, :change_data_rnd, :change_data_rnm, :change_data_da, :change_data_aom, :report ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
    
  def index
    @redir = params[:redir]
    p @redir
    @budgets=Budget.where(:cost_center_id => get_company_cost_center('cost_center'))
    render :index, :layout => false
  end
  
  def newvalorization
    @itembybudgets = Itembybudget.all
    @budget = Budget.find(params[:id])
    @valorization = Valorization.new
    @valorization.budget_id = @budget.id 

    all_budgets = Budget.where(:cost_center_id => @budget.cost_center_id)
    @num_val = 1
    all_budgets.each do |i|
      @num_val = @num_val + Valorization.where(budget_id: i.id).count
    end

    render :newvalorization, layout: false
  end

  def edit
     @valorization = Valorization.find(params[:id])
     render :edit, layout: false
  end

  def update
      @valorization = Valorization.find(params[:id])
      @valorization.update_attributes(valorization_parameters)
      cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

      redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def destroy
    @redir = params[:redir]
    @valorization = Valorization.find(params[:id])
    @valorization.destroy

    # project = CostCenter.find(get_company_cost_center('cost_center'))
    # @valorization = project.valorizations
    # @budget = project.budgets
    #render "management/budgets/administrate_budget", layout: false
    @budgets=Budget.where(:cost_center_id => get_company_cost_center('cost_center'))
    render action: :index, redir: 1, layout: false
  end


  def changevalorization
  	@itembybudgets = Itembybudget.all
    @valorization = Valorization.find(params[:id])
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id) rescue 0
 

    str_query = "SELECT  itembybudgets.id, 
                  IF(itembybudgets.subbudgetdetail = '', itembybudgets.title, itembybudgets.subbudgetdetail),  
                  itembybudgets.order,  
                  IFNULL(get_prev_valorizations('" + @valorization.valorization_date.to_s.gsub('UTC', '') + "', itembybudgets.id),0), 
                  measured,
                  IFNULL(valorizationitems.actual_measured, 0) as valorization_actual
                  FROM itembybudgets LEFT JOIN valorizationitems
                  ON valorizationitems.itembybudget_id=itembybudgets.id AND
                  valorizationitems.valorization_id = '" + @valorization.id.to_s + "'
                  WHERE itembybudgets.budget_id = '" + @budget.id.to_s + "'
                ORDER BY itembybudgets.`order`;"
    p str_query

    @results = ActiveRecord::Base.connection.execute(str_query) 
    

    @valorization.semicomplete

    render :changevalorization, layout: false
  end

  def create
    valorization = Valorization.new(valorization_parameters)
    valorization.month = "Valorizacion : " + valorization.valorization_date.strftime("%B %Y")

    valorization.save

    cost_center_id = Budget.find(valorization.budget_id).cost_center_id

    redirect_to :controller => "management/budgets", project_id: cost_center_id, :action => :administrate_budget
  end

  def finalize
    @valorization = Valorization.find(params[:id])
    @valorization.complete!

    cost_center_id = Budget.find(@valorization.budget_id).cost_center_id

    redirect_to :controller => "management/budgets", project_id: cost_center_id ,:action => :administrate_budget
  end

  def show_data
    @valorization = Valorization.find(params[:id])
    
    @month = @valorization.valorization_date.to_date.strftime("%-m").to_i
    @year = @valorization.valorization_date.to_date.strftime("%Y").to_i 

    render :show_data, layout: false
  end

  ###~###
  def change_data_ge
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.general_expenses = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_u
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.utility = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_r
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.readjustment = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_rnd
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.no_direct_r = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_rnm
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.no_materials_r = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_da
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.direct_advance = new_value
    @valorization.save
    render :show_data, layout: false
  end

  def change_data_aom
    @valorization = Valorization.find(params[:id])
    new_value = params[:new_value]

    @valorization.advance_of_materials = new_value
    @valorization.save
    render :show_data, layout: false
  end
  ###~###

  def report
    @valorization = Valorization.find(params[:id])
    @itembybudgets = Itembybudget.where('CHAR_LENGTH(`order`) > 3 AND budget_id = ?', @valorization.budget_id)
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id)

    @project = CostCenter.find(@budget.cost_center_id)

    @itembybudgets_main = Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', @valorization.budget_id)
    
    @month = @valorization.valorization_date.to_date.strftime("%-m").to_i
    @year = @valorization.valorization_date.to_date.strftime("%Y").to_i 


    @report_rows = ReportValorization.where(valorization_id: params[:id])
    @last_result = Inputbybudgetanditem.all.order(:order).last

    render :report, layout: false
  end

  def short_report
    @valorization = Valorization.find(params[:id])
    @itembybudgets = Itembybudget.where('CHAR_LENGTH(`order`) > 3 AND budget_id = ?', @valorization.budget_id)
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id)

    @project = CostCenter.find(@budget.cost_center_id)

    @itembybudgets_main = Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', @valorization.budget_id)
    
    @month = @valorization.valorization_date.to_date.strftime("%-m").to_i
    @year = @valorization.valorization_date.to_date.strftime("%Y").to_i 

    render :short_report, layout: false
  end

  def generate_report
    val_id = params[:val_id]
    ReportValorization.delete_all
    @valorization = Valorization.find(val_id)
    @itembybudgets = Itembybudget.where('CHAR_LENGTH(`order`) > 3 AND budget_id = ?', @valorization.budget_id)
    @budget = Budget.where(:id => @valorization.budget_id).first

    @valorizationitem = Valorizationitem.where(:valorization_id => @valorization.id)

    @itembybudgets_main = Itembybudget.select('id, `title`, `subbudgetdetail`, `order`, CHAR_LENGTH(`order`)').where('CHAR_LENGTH(`order`) < 3 AND budget_id = ?', @valorization.budget_id)
    
    hash_items = Hash.new
    @itembybudgets_main.each do |ib|
      rep = ReportValorization.new
      rep.valorization_id = val_id
      rep.order = ib.order
      rep.description = ib.subbudgetdetail == ''? ib.title : ib.subbudgetdetail
      rep.con_amount = Valorization.amount_contractual(ib.order, @budget.id)
      rep.pre_amount = Valorization.amount_prev(ib.order, @budget.id, @valorization.valorization_date)
      rep.act_amount = Valorization.amount_actual(ib.order, @budget.id, @valorization.id)
      rep.acc_amount = Valorization.amount_acumulated(ib.order, @budget.id, @valorization.valorization_date, @valorization.id)
      rep.rem_amount = Valorization.amount_remainder(ib.order, @budget.id, @valorization.valorization_date, @valorization.id)
      rep.advance = Valorization.advance_percent(ib.order, @budget.id, @valorization.valorization_date, @valorization.id)
      rep.save

      si_prev = Hash.new
      vals = Valorization.where("valorization_date < ? AND budget_id = ?", @valorization.valorization_date.to_s, @valorization.budget_id).order(:valorization_date)
      vals.each do |vs|
        val = Valorization.get_sub_itembybudgets(ib.order, vs.id.to_s, @valorization.budget_id)
        val.each do |v|
          si_prev[v[2]] = [v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[10], v[11], 0.0, 0.0, v[12], v[13], v[14], v[15], v[16]]
        end
      end

      sub_item = Valorization.get_sub_itembybudgets(ib.order.to_s, @valorization.id.to_s, @budget.id.to_s)
      sub_item.each do |si|
        key_str = si[0].to_s
        if key_str != nil
          if si != nil
            hash_items[key_str] = si  
          end
        end
      end

      @itembybudgets.where("`order` LIKE ?", ib.order.to_s + "%").each do |ibb|
        rep = ReportValorization.new

        si = hash_items[ibb.id.to_s]
        
        rep.valorization_id = val_id
        rep.order = ibb.order
        rep.description = ibb.subbudgetdetail == ''? ibb.title : ibb.subbudgetdetail

        if (ibb.measured != nil) && (ibb.measured > 0)
          measured = si[6].to_f rescue 0
          if measured > 0
            rep.price = si[5].to_f
            rep.con_measured = si[6].to_f
            rep.con_amount = si[5].to_f
            rep.pre_measured = si[8].to_f
            rep.pre_amount = si[9].to_f
            rep.act_measured = si[10].to_f
            rep.act_amount = si[11].to_f
            rep.acc_measured = si[12].to_f
            rep.acc_amount = si[13].to_f
            rep.rem_measured = si[14].to_f
            rep.rem_amount = si[15].to_f
            rep.advance = si[16].to_f #PORCENTAJE DE AVANCE
            rep.save
          elsif si_prev[ibb.order] != nil     
            rep.price = si_prev[ibb.order][5].to_f 
            rep.con_measured = si_prev[ibb.order][6].to_f 
            rep.con_amount = si_prev[ibb.order][7].to_f 
            rep.pre_measured = si_prev[ibb.order][8].to_f
            rep.pre_amount = si_prev[ibb.order][9].to_f 
            rep.act_measured = si_prev[ibb.order][10].to_f 
            rep.act_amount = si_prev[ibb.order][11].to_f 
            rep.acc_measured = si_prev[ibb.order][12].to_f
            rep.acc_amount = si_prev[ibb.order][13].to_f 
            rep.rem_measured = si_prev[ibb.order][14].to_f
            rep.rem_amount = si_prev[ibb.order][15].to_f
            rep.advance = si_prev[ibb.order][16].to_f
            rep.save
          else
            rep.price = ibb.price
            rep.con_measured = ibb.measured
            rep.con_amount = ibb.price * ibb.measured
            rep.pre_measured = '-'
            rep.pre_amount = '-'
            rep.act_measured = '-'
            rep.act_amount = '-'
            rep.acc_measured = '-'
            rep.acc_amount = '-'
            rep.rem_measured = ibb.measured
            rep.rem_amount = ibb.price * ibb.measured
            rep.advance = 0.0
            rep.save
          end
        else
          rep.con_amount = Valorization.amount_contractual(ibb.order, @budget.id)
          rep.pre_amount = Valorization.amount_prev(ibb.order, @budget.id, @valorization.valorization_date)
          rep.act_amount = Valorization.amount_actual(ibb.order, @budget.id, @valorization.id)
          rep.acc_amount = Valorization.amount_acumulated(ibb.order, @budget.id, @valorization.valorization_date, @valorization.id)
          rep.rem_amount = Valorization.amount_remainder(ibb.order, @budget.id, @valorization.valorization_date, @valorization.id)
          rep.advance = Valorization.advance_percent(ibb.order, @budget.id, @valorization.valorization_date, @valorization.id) rescue 0.0
          rep.save
        end
      end
    end

    rendirect_to action: :index
  end

  private
  def valorization_parameters
    params.require(:valorization).permit(:month, :name, :status, :budget_id, :valorization_date)
  end

end
