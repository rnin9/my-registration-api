class AddIsDestroyedToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :is_destroyed, :boolean
  end
end
