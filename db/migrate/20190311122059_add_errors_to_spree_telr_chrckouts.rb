class AddErrorsToSpreeTelrChrckouts < ActiveRecord::Migration[5.2]
  def change
    add_column :spree_telr_checkouts, :telr_errors, :jsonb
  end
end
