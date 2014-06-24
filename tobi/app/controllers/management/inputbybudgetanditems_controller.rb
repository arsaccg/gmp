class Management::InputbybudgetanditemsController < ApplicationController
  before_filter :authorize_manager

  def index
    @itembybudgetanditems = Inputbybudgetanditem.all
  end

  def filter_by_budget_and_item
  	@item_id = params[:item_id]
  	@budget_id = params[:budget_id]
    @order = params[:order].gsub("d",".")

    @pdf_table_array = Array.new

  	@itembybudgetanditems = Inputbybudgetanditem.select("cod_input, sum(quantity) as quantity, price, input, unit").where("budget_id = ? AND inputbybudgetanditems.order LIKE ?", params[:budget_id],  @order + "%").group(' cod_input, price, input, unit').order(:cod_input)
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

    render :nothing => true, :status => 200, :content_type => 'text/html', layout: false
    #render :filter_by_budget_and_item, budget_id: @item.budget_id, item_id: @item.item_id, order: @item.order, :layout => false
  end

  private
  def itembybudgetanditem_parameters
    params.require(:itembybudgetanditem).permit(:coditem, :cod_input, :quantity, :price, :order, :input, :budget_id, :subbudget_code, :item_id, :unit)
  end
end

 