class Logistics::SectorsController < ApplicationController
  def index
    @sectors = Sector.all
  end

  def new
    @sector = Sector.new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end
end
