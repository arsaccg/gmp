class Management::InvoicesController < ApplicationController
  before_filter :authorize_manager
end
