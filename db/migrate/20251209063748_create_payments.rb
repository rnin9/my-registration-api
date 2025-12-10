class CreatePayments < ActiveRecord::Migration[7.1]
  def change
    create_table :payments, id: :uuid do |t|
      t.uuid :user_id, null: false
      t.integer :amount, null: false
      t.string :method
      t.string :status, null: false
      t.string :target_type, null: false
      t.string :target_id, null: false
      t.string :title, null: false
      t.datetime :paid_at
      t.datetime :cancelled_at
      t.date :valid_from, null: false
      t.date :valid_to, null: false
      t.boolean :is_destroyed, default: false, null: false

      t.timestamps
    end

    add_index :payments, :user_id
    add_index :payments, :status
    add_index :payments, :target_type
    add_index :payments, :target_id
    add_index :payments, [ :target_type, :target_id ]
    add_index :payments, :is_destroyed
    add_index :payments, :valid_from
    add_index :payments, :valid_to

    add_foreign_key :payments, :users, column: :user_id
  end
end
