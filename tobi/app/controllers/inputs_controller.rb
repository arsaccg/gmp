class InputsController < ApplicationController
  
  def index
    @inputs = Input.all
    render layout: false
  end
  
  def new
    @input = Input.new
    render layout: false
  end
  
  def edit
    @input = Input.find(params[:id])
    render layout: false
  end
  
  def show
    @input = Input.find(params[:id])
    render layout: false
  end
  
  def update
    @input = Input.find(params[:id])
    
  end
  
  def create
    input = Input.new(input_parameters)

    units_selected = params[:units_selected]
    if params[:ancestry] != nil && params[:ancestry] != "0"
      ancestry = Input.find(params[:ancestry])
      if ancestry
        input.code = ancestry.code + input.code;
      end
    end

    if (input.save)
      if (units_selected != nil)
        units_selected.each do |k, unit|
          input_unit = InputUnit.new
          input_unit.input_id = input.id
          input_unit.unit_id = unit['id']
          input_unit.save
        end
      end
    end

    redirect_to :action => 'index'
    
  end

  def add_input_unit
    @val_input = params['value']
    @text_input = params['text']
    @input_code = params['code']
    @time_stamp = Time.now.strftime("%H%M%S")
    render :partial => 'input_field'
  end
  
  def destroy
    input = Input.find(params[:id])
    input.destroy!
    redirect_to action: :index
  end

  private
  def input_parameters
    params.require(:input).permit(:code, :name)
  end
  
end
