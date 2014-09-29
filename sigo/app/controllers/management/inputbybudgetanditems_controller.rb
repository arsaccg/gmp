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

    @measured = params[:measured] rescue 0.0

    @pdf_table_array = Array.new

  	@itembybudgetanditems = Inputbybudgetanditem.select("id, cod_input, sum(quantity) as quantity, price, input, unit").where("budget_id = ? AND inputbybudgetanditems.order LIKE ?", params[:budget_id],  @order + "%").group(' cod_input, price, input, unit').order(:cod_input)
    p @itembybudgetanditems
    @pdf_table_array << ["Insumo", "Codigo", "Cantidad", "Unidad", "Precio", "Total"]

    if @itembybudgetanditems != nil
      @itembybudgetanditems.each do |itembudget|
        @pdf_table_array << [itembudget.input, itembudget.cod_input,  itembudget.quantity.to_f.round(4), itembudget.unit, itembudget.price.round(4), (itembudget.quantity.to_f * itembudget.price.to_f).round(4) ]
      end
    end

    render :index, :layout => false
  end
  
  def update_input
    input = Inputbybudgetanditem.find(params[:input_id])
    input.price = params[:price]
    input.quantity = params[:quantity]
    input.save
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
        @pdf_table_array << [itembudget.input, itembudget.cod_input,  itembudget.quantity.to_f.round(4), itembudget.unit, itembudget.price.round(4), (itembudget.quantity.to_f * itembudget.price.to_f).round(4) ]
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
    @item.unit = params[:unit]

    p "****************Inputbybudgetanditem*****************"
    @item.save

    #render :nothing => true, :status => 200, :content_type => 'text/html', layout: false
    redirect_to filter_by_budget_and_item_management_inputbybudgetanditems_path + "?budget_id=" + @item.budget_id.to_s + "&item_id=" + @item.item_id.to_s + "&order=" + @item.order.gsub(".","d")
  end

  private
  def itembybudgetanditem_parameters
    params.require(:itembybudgetanditem).permit(:coditem, :cod_input, :quantity, :price, :order, :input, :budget_id, :subbudget_code, :item_id, :unit)
  end
end

 