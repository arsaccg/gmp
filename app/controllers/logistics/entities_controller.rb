class Logistics::EntitiesController < ApplicationController
  def index
    @type_entities = TypeEntity.all
    render layout: false
  end

  def show
  end

  def new
    render layout: false
  end

  def create
  end

  def edit
    render layout: false
  end

  def update
  end

  def destroy
  end

  private
  def entity_parameters
    params.require(:entity).permit(:name, :surname, :dni, :ruc)
  end
end
