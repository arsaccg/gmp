class Logistics::MainController < ApplicationController
  before_filter :authenticate_user!
  def index
  	render layout: 'dashboard'
  end
end
