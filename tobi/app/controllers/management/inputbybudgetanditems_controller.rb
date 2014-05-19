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
end

 