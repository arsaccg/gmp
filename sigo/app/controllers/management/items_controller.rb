class Management::ItemsController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!
  def index
  end

  def new
  end

  def show
  end
end
