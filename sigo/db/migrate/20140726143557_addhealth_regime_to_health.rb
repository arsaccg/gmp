class AddhealthRegimeToHealth < ActiveRecord::Migration
  def change
    add_column :worker_healths, :health_regime, :string
  end
end
