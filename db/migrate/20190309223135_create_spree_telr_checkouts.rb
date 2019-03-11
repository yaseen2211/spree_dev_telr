class CreateSpreeTelrCheckouts < ActiveRecord::Migration[5.2]
  def change
    create_table :spree_telr_checkouts do |t|
	  t.string :ref
	  t.string :transaction_id
	  t.string :state
	  t.string :refund_transaction_id
	  t.datetime :refunded_at
	  t.string :refund_type
      t.timestamps
	  t.index :transaction_id, unique: true
    end
  end
end
