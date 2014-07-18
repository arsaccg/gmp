class Administration::AccountAccountantsController < ApplicationController
  def index
  end

  def new
  end

  def create
  end

  def edit
  end

  def update
  end

  def destroy
  end

  def import
  end

  private
  def account_accountant_parameters
    params.require(:account_accountant).permit!
  end
end
