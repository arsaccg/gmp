load 'socket_connector/socket_connector.rb'

class Management::WbsitemsController < ApplicationController
  before_filter :authorize_manager
  before_filter :authenticate_manager!
  layout "dashboard"

  include SOCKET_CONNECTOR
  
  def index
  	@wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs)  
    @result = get_child("1")

    @fourth=0 

    @result.each do |secundary_key_item, secunday_item|
      secunday_item_flag = secunday_item.count rescue nil
      if secunday_item_flag != nil
        secunday_item.each do |third_key_item, third_item|
          third_item_flag = third_item.count rescue 1
          @fourth += third_item_flag
        end  
      else
        @fourth += 1
      end
    end 

    respond_to do |format|
      format.html {
        render :index, layout: false
      }
      format.json  { 
        render :json => @wbsitems.to_json
      }
    end


  end

  def get_items_json 
     @result = get_child(params[:project_id].to_s)
     respond_to do |format|
      format.json  { 
        render :json => @result.to_json
      }
    end
  end

  def show_measured
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs) 
    @itembywbses = Array.new
    @wbsitems.each do |item|
      item.itembywbses.each do |i|
        @itembywbses << i
      end
    end
    #sirve el de arriba #@inputbybudgetanditems = Inputbybudgetanditem.where("budget_id = ?", params[:budget_id])

    render :show_measured, layout: false
  end

 

  def new    
  	@wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs)  
  	@wbsitem = Wbsitem.new 

  	render :new, layout: false
  end

  def update
    @wbsitem = Wbsitem.find(params[:id])  
    @wbsitem.update_attributes(wbsitem_parameters)
    render :index, layout: false
  end

  def edit    
    @wbsitem = Wbsitem.find(params[:id])  
    
    render :edit, layout: false
  end

  def show
  	@wbsitem = Wbsitem.find(params[:id])
  	render :show, layout: false
  end

  def get_items_from_project
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs)  
    @data = Array.new
    data = ask_socket("select * from log_fases")
    data.each do |item|
      arr = Array.new
      arr_str = item.gsub("(", "[").gsub(")", "]").gsub("None", "''").gsub("EOF", "")
      begin
        puts arr_str.to_s
        begin
            @data << eval(arr_str)
        rescue Exception => exc
            puts "RESCUED!"
        end
        
      rescue 
        puts "ERROR : " + arr_str.to_s
      end
    end

    render :get_items_from_project, layout: false
  end

  def destroy

    wbsitem = Wbsitem.find(params[:id])
    wbsitemchilds = Wbsitem.where("codewbs LIKE ?", wbsitem.codewbs + "%")
    code = wbsitem.codewbs

    c=code.length-1

    parent_item = Wbsitem.where("codewbs = ?", code.to_s[0..c-1]).first

    #delete childs
    wbsitemchilds.each do |wbs_item|
      wbs_item.destroy
    end

    n=0

    puts "PARENT "
    puts parent_item.inspect
    puts code.to_s[0..c-1]

    if parent_item != nil
      
      wbsitem_parent_sons = Wbsitem.where("codewbs LIKE ?", code.to_s[0..c-1] + "_").order(:codewbs)
      n=0
      wbsitem_parent_sons.each do |son|
        n=n+1
        son.codewbs=code.to_s[0..c-1] + n.to_s
        son.save
      end
    end

    @wbsitems = Wbsitem.order(:codewbs)
    render :get_items_from_project, layout: false

  end

  def add_items_to_wbs

  	@wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs)

  	@budgets = Budget.where("cost_center_id = ? AND type_of_budget = ?", params[:project_id], params[:type_budget])
  	@wbsitems_arr = Array.new
  	@budgets.each do |budget|
  		temp_wbsitems = budget.itembywbses
  		temp_wbsitems.each do |item| 
  			@wbsitems_arr << item
  		end
  	end
  	render :add_items_to_wbs, layout: false

  end

  

  def get_items_by_budget
  	@items = Itembybudget.where(:budget_id => params[:budget_id].to_s)
  	#@items = Itembybudget.find(:all, :conditions => ['budget_code LIKE ?', params[:budget_id].to_s + "%"])
  	render :get_items_by_budget, layout: false
  end

  def get_items_by_wbs_code
  	#@wbsitem = Item.find(:all, :conditions => ["wbs_parent_code IS NOT NULL OR wbs_parent_code <> ''"])

  end

  def create 
  	if (params[:major_item]!=nil)
	  	wbsitem_selected = Wbsitem.find(params[:major_item])

	  	last_id = Wbsitem.find(:all, :conditions=>["codewbs like ?", wbsitem_selected.codewbs + "_"]).count
	  	last_id_total = Wbsitem.find(:all, :conditions=>["codewbs like ?", wbsitem_selected.codewbs + "%"]).count
	  	
	  	wbsitem = Wbsitem.new(wbsitem_parameters)
	  	if last_id_total.to_s == "0"
	  		wbsitem.codewbs = wbsitem_selected.codewbs + (last_id).to_s
	  	else
	  		wbsitem.codewbs = wbsitem_selected.codewbs + (last_id+1).to_s
	  	end
  	else
  		wbsitem = Wbsitem.new(wbsitem_parameters)
  		wbsitem.codewbs=params[:wbsitem][:project_id];
  	end
  	wbsitem.save
  	redirect_to :action =>:index
  end

  def get_json_data

  	filter = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%")

  	puts "FILTER"
  	p filter

  	array_initial = Array.new
  	 filter.each do |item|
  		n=item.codewbs.size-2
  		#if n==0
  		parent_code = item.codewbs[0..n]
  		#else
  		if parent_code ==  item.codewbs
  			parent_code = nil
  		end
  		#	parent_code = ''
  		#end
  		if (item.codewbs.length > 1)
  			array_initial << [{v: item.codewbs, f: "<span data-toggle='tooltip' title='" + item.description + "'>" + item.name + "</span><br/> " + item.codewbs[1..item.codewbs.length]}, parent_code, '']
  		else
  			array_initial << [{v: item.codewbs, f: item.name}, parent_code, '']
  		end
  	end

  	respond_to do |format|
  	  format.json  { 
  	  	render :json => array_initial.to_json
  	  }

  	end
  	
  end

  def get_child(str_id=nil)
  	puts str_id.to_s + "%"
  	
  		temp_hash = Hash.new

	  	for i in 1..9
	  		item_wbs=Wbsitem.where(:codewbs => str_id.to_s + i.to_s).first
	  		puts "ITEM : " + item_wbs.inspect

	  		if item_wbs !=nil
	  			puts "COMPARATION" 
	  			puts str_id.to_s + i.to_s + "%"
	  			if Wbsitem.where("codewbs like ?", str_id.to_s + i.to_s + "_").count >0
	  				temp_hash['code' + str_id.to_s + i.to_s] = get_child(str_id.to_s + i.to_s)
	  			else
             temp_hash['code' + str_id.to_s + i.to_s] = str_id.to_s + i.to_s
            #end
	  			end
	  		end
	  	end
	  	
	  	#else
		return temp_hash
		#end
  	#else
  		#return Wbsitem.where(str_id).name
  	#end


    

  end

  def set_gantt
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs) 

    @wbsitems_xls = @wbsitems.select('id, codewbs, name')

    respond_to do |format|
      format.html {render :set_gantt, layout: false}
      format.csv {send_data @wbsitems_xls.to_csv}
      format.xls {send_data @wbsitems_xls.to_csv(col_sep: "\t")}
    end

  end

  def save_gantt
    @data = params[:data]
    @data.each do |k, v|
      wbsitem = Wbsitem.find(k)
      wbsitem.start_date = v["start_date"]
      wbsitem.end_date = v["end_date"]
      wbsitem.predecessors = v["predecessors"]
      wbsitem.save
    end
    render status: 200
  end

  def graph_gantt
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs) 
    
    respond_to do |format|
      format.html {
        render :graph_gantt, layout: false
      }
      format.json  { 
        render :json => @wbsitems.to_json
      }
    
    end

  end

  #para mostrar x mes
  def showbymonth_gantt
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs) 
    @itembywbses = Array.new
    @wbsitems.each do |item|
      item.itembywbses.each do |i|
        @itembywbses << i
      end
    end
    #sirve el de arriba #@inputbybudgetanditems = Inputbybudgetanditem.where("budget_id = ?", params[:budget_id])

    render :showbymonth_gantt, layout: false
  end

  def add_phases_to_item
    wbsitem_id = params[:wbsitem_id]
    @phase = params[:phase_id]
    @wbsitem = Wbsitem.find(wbsitem_id)
    @wbsitem.fase = @phase
    @wbsitem.save
  end

  def showperitem_gantt
    @wbsitems = Wbsitem.where("codewbs LIKE ?", params[:project_id].to_s + "%").order(:codewbs) 
    @itembywbses = Array.new
    @wbsitems.each do |item|
      item.itembywbses.each do |i|
        @itembywbses << i
      end
    end
    #sirve el de arriba #@inputbybudgetanditems = Inputbybudgetanditem.where("budget_id = ?", params[:budget_id])

    render :showperitem_gantt, layout: false
  end

  private
  def wbsitem_parameters
    params.require(:wbsitem).permit(:codewbs, :name, :description, :notes, :project_id, :item_id)
  end

end
