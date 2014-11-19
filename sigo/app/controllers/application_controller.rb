class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  layout :layout_by_resource
  protect_from_forgery with: :exception

  def layout_by_resource
    if devise_controller?
      false
    else
      'application'
    end
  end

  def record_activity(note)
    @watchdog = Watchdog.new
    @watchdog.user = current_user
    @watchdog.note = note
    @watchdog.browser = request.env['HTTP_USER_AGENT']
    @watchdog.ip_address = request.env['REMOTE_ADDR']
    @watchdog.save
  end

  def exchange_rate_per_date(date, money)
    return ActiveRecord::Base.connection.execute("SELECT  `value` FROM  `exchange_of_rates` WHERE DATE(`day`) = '#{date}' AND `money_id` = #{money} ORDER BY 1 DESC LIMIT 1")
  end

  def get_company_cost_center(type)
    case type
      when 'company'
        return session[:company]
      when 'cost_center'
        return session[:cost_center]
      else
        return false
    end
  end

  def save_summary_data_accounting(account_accountant_id, sub_daily_id, accounting_date, amount)
    summary = DataSummaryAccounting.new(:account_accountant_id => account_accountant_id, :sub_daily_id => sub_daily_id, :accounting_date => accounting_date, :amount => amount)
    summary.save!
  end

  def get_sumatory_one_to_one(order, budget)
    total_sum = 0
    inputs = Inputbybudgetanditem.where("`order` LIKE ? AND budget_id = ? ", order + "%", budget)
    inputs.each do |item|
      price = item.price.to_f.round(4).to_s.to_f
      quantity = item.quantity.to_f.round(4).to_s.to_f
      partial = (price.round(4) * quantity.round(4)).round(2)

      total_sum = total_sum + partial.round(2)
    end
    return total_sum
  end

end
