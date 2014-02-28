class UnitOfMeasurementController < ApplicationController
  # GET /anhos
  # GET /anhos.json
  def index
    @UnitOfMeasurement = UnitOfMeasurement.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @@UnitOfMeasurement }
    end
  end

  # GET /anhos/1
  # GET /anhos/1.json
  def show
    @UnitOfMeasurement = UnitOfMeasurement.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @UnitOfMeasurement }
    end
  end

end
