class Management::EquivalenceOfItemsController < ApplicationController
  before_filter :authenticate_user!, :only => [:index, :new, :create, :edit, :update ]
  protect_from_forgery with: :null_session, :only => [:destroy, :delete]
  def index
    @equivalences = EquivalenceOfItem.all
    render layout: false
  end  
end