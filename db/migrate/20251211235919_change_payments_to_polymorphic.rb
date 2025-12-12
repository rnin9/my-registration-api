class ChangePaymentsToPolymorphic < ActiveRecord::Migration[7.1]
  def change
    change_column :payments, :target_id, :bigint, using: 'target_id::bigint'
  end
end
