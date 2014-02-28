class UnitOfMeasurementController < ApplicationController
  def index
    @unitOfMeasures = UnitOfMeasure.all
    render layout: false
  end

  def create
  end

  def edit
  end

  def show
  end

  def update
  end

  def new
  end

  def destroy
  end
end
