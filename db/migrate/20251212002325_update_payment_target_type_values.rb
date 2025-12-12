class UpdatePaymentTargetTypeValues < ActiveRecord::Migration[7.1]
  def up
    execute "UPDATE payments SET target_type = 'Test' WHERE target_type = 'TEST'"
    execute "UPDATE payments SET target_type = 'Course' WHERE target_type = 'COURSE'"
  end

  def down
    execute "UPDATE payments SET target_type = 'TEST' WHERE target_type = 'Test'"
    execute "UPDATE payments SET target_type = 'COURSE' WHERE target_type = 'Course'"
  end
end