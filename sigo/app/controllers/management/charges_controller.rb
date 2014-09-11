class Management::ChargesController < ApplicationController
	  before_filter :authorize_manager
end
