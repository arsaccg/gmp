class Management::InputbybudgetanditemsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]

  def index
    @itembybudgetanditems = Inputbybudgetanditem.all
  end

  def filter_by_budget_and_item
  	@item_id = params[:item_id]
  	@budget_id = params[:budget_id]
    @budget = Budget.find(@budget_id)
    @order = params[:order].gsub("d",".")

    @measured = params[:measured] rescue "0.0"
    @must_be_blocked = @measured.to_f > 0 ? false : true

    @pdf_table_array = Array.new

  	if @measured.to_f > 0
      #@itembybudgetanditems = Inputbybudgetanditem.select("id, cod_input, quantity, price, input, unit").where("budget_id = ? AND inputbybudgetanditems.order LIKE ?", params[:budget_id],  @order + "%").group('').order(:cod_input)
      @itembybudgetanditems = ActiveRecord::Base.connection.execute("SELECT ibi.id, ibi.cod_input, ibi.quantity AS quantity, ibi.price, ibi.input, ibi.unit
      FROM  `inputbybudgetanditems` AS ibi
      WHERE ibi.`order` LIKE  '" +@order+ "'
      AND ibi.`budget_id` ="+@budget_id+"
      ORDER BY ibi.cod_input")
    else
      @itembybudgetanditems = ActiveRecord::Base.connection.execute("SELECT ibi.id, ibi.cod_input, SUM( ibi.quantity * ib.measured ) AS quantity, ibi.price, ibi.input, ibi.unit
      FROM  `inputbybudgetanditems` AS ibi,  `itembybudgets` AS ib
      WHERE ibi.`order` LIKE  '" +@order+ "%'
      AND ibi.`order` = ib.`order` 
      AND ibi.`budget_id` ="+@budget_id+"
      AND ib.`budget_id` ="+@budget_id+"
      GROUP BY ibi.cod_input, ibi.price
      ORDER BY ibi.cod_input")
    end

    p @itembybudgetanditems
    @pdf_table_array << ["Insumo", "Codigo", "Cantidad", "Unidad", "Precio", "Total"]

    if @itembybudgetanditems != nil
      @itembybudgetanditems.each do |itembudget|
        @pdf_table_array << [ itembudget[4], itembudget[1], itembudget[2].to_f.round(4), itembudget[5], itembudget[3].to_f.round(4), (itembudget[2].to_f * itembudget[3].to_f).round(4) ]
      end
    end
    render :index, :layout => false
  end
  
  def update_input
    input = Inputbybudgetanditem.find(params[:input_id])
    input.price = params[:price]
    input.quantity = params[:quantity]
    input.save

    itembybudget = Itembybudget.where('`order` LIKE ? AND `item_code` LIKE ? AND `budget_id` = ?', input.order, input.coditem, input.budget_id).first
    itembybudget.price = get_sumatory_one_to_one(input.order, input.budget_id)

    p "~~~~~~~~~~~itembybudget.price~~~~~~~~~~~"
    p itembybudget.price
    itembybudget.save
    p itembybudget

    render :nothing => true, :status => 200, :content_type => 'text/html', layout: false
  end

  def update_input_group
    #actualizar precio en grupo
    main_order = params[:order].gsub("d",".")
    new_price = params[:price]

    input = Inputbybudgetanditem.find(params[:input_id])
    if input.cod_input != '0359700510'
      inputs = Inputbybudgetanditem.where('`order` LIKE ? AND `budget_id` = ? AND `cod_input` = ?', main_order+'%', input.budget_id, input.cod_input)

      inputs.each do |i|
        i.price = new_price
        p "~~~~~~~~~~~itembybudgetanditem~~~~~~~~~~~"
        p i
        i.save
        itembybudget = Itembybudget.where('`order` LIKE ? AND `item_code` LIKE ? AND `budget_id` = ?', i.order, i.coditem, i.budget_id).first
        itembybudget.price = get_sumatory_one_to_one(i.order, i.budget_id)  
        p "~~~~~~~~~~~itembybudget.price~~~~~~~~~~~"
        p itembybudget.price
        itembybudget.save
        p itembybudget
      end
    end
    
    render :nothing => true, :status => 200, :content_type => 'text/html', layout: false
  end

  def destroy
    @item_id = params[:item_id]
    @budget_id = params[:budget_id]
    @budget = Budget.find(@budget_id)
    @order = params[:order].gsub("d",".")

    input = Inputbybudgetanditem.find(params[:id]).destroy

    @pdf_table_array = Array.new

    @itembybudgetanditems = Inputbybudgetanditem.select("id, cod_input, sum(quantity) as quantity, price, input, unit").where("budget_id = ? AND inputbybudgetanditems.order LIKE ?", params[:budget_id],  @order + "%").group(' cod_input, price, input, unit').order(:cod_input)
    p @itembybudgetanditems
    @pdf_table_array << ["Insumo", "Codigo", "Cantidad", "Unidad", "Precio", "Total"]

    if @itembybudgetanditems != nil
      @itembybudgetanditems.each do |itembudget|
        @pdf_table_array << [itembudget.input, itembudget.cod_input,  itembudget.quantity.to_f.round(4), itembudget.unit, itembudget.price.to_f.round(4), (itembudget.quantity.to_f * itembudget.price.to_f).round(4) ]
      end
    end

    render :index, :layout => false
  end

  def add
    @item = Inputbybudgetanditem.new
    @item.coditem = params[:coditem]
    @item.cod_input = params[:cod_input]
    @item.quantity = params[:quantity]
    @item.price = params[:price]
    @item.order = params[:order].gsub('a', '.')
    @item.input = params[:input].gsub('_', ' ')
    @item.budget_id = params[:budget_id]
    @item.subbudget_code = params[:subbudget_code]
    @item.item_id = params[:item_id]
    @item.unit = params[:unit].gsub('_', '%')

    p "****************Inputbybudgetanditem*****************"
    @item.save

    #render :nothing => true, :status => 200, :content_type => 'text/html', layout: false
    redirect_to filter_by_budget_and_item_management_inputbybudgetanditems_path + "?budget_id=" + @item.budget_id.to_s + "&item_id=" + @item.item_id.to_s + "&order=" + @item.order.gsub(".","d") + "&measured=1"
  end

  private
  def itembybudgetanditem_parameters
    params.require(:itembybudgetanditem).permit(:coditem, :cod_input, :quantity, :price, :order, :input, :budget_id, :subbudget_code, :item_id, :unit)
  end
end

 