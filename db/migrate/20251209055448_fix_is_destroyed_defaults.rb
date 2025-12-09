class FixIsDestroyedDefaults < ActiveRecord::Migration[7.1]
  def up
    # 1. users 테이블
    change_column_default :users, :is_destroyed, false
    User.where(is_destroyed: nil).update_all(is_destroyed: false)
    change_column_null :users, :is_destroyed, false

    # 2. tests 테이블
    change_column_default :tests, :is_destroyed, false
    Test.where(is_destroyed: nil).update_all(is_destroyed: false)
    change_column_null :tests, :is_destroyed, false

    # 3. courses 테이블
    change_column_default :courses, :is_destroyed, false
    Course.where(is_destroyed: nil).update_all(is_destroyed: false)
    change_column_null :courses, :is_destroyed, false
  end

  def down
    # Rollback (필요시)
    change_column_null :users, :is_destroyed, true
    change_column_default :users, :is_destroyed, nil

    change_column_null :tests, :is_destroyed, true
    change_column_default :tests, :is_destroyed, nil

    change_column_null :courses, :is_destroyed, true
    change_column_default :courses, :is_destroyed, nil
  end
end