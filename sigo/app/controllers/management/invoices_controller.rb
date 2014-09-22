class Management::InvoicesController < ApplicationController
  #before_filter :authorize_manager
  before_filter :authenticate_user!
end
