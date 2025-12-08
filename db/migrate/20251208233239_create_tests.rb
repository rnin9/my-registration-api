class CreateTests < ActiveRecord::Migration[7.1]
  def change
    create_table :tests do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.datetime :start_at, null: false
      t.datetime :end_at, null: false
      t.string :status, null: false, default: 'AVAILABLE'
      t.integer :examinee_count, default: 0
      t.boolean :is_destroyed, default: false, null: false
      t.references :actant, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
