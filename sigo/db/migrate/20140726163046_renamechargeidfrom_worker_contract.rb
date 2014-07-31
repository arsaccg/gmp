class RenamechargeidfromWorkerContract < ActiveRecord::Migration
  def change
  	rename_column(:worker_contracts, :charge_id, :article_id)
  end
end
