class AddTeacherContentManagement < ActiveRecord::Migration[8.1]
  def up
    add_column :users, :role, :string, null: false, default: "student"
    add_check_constraint :users, "role IN ('student', 'teacher')", name: "users_role_allowed"

    add_column :quiz_modules, :published, :boolean, null: false, default: false
    execute "UPDATE quiz_modules SET published = TRUE"
    add_reference :quiz_modules, :created_by, foreign_key: { to_table: :users }
    add_index :quiz_modules, :published

    add_column :questions, :published, :boolean, null: false, default: false
    execute "UPDATE questions SET published = TRUE"
    add_index :questions, [ :quiz_module_id, :published ]
  end

  def down
    remove_index :questions, [ :quiz_module_id, :published ]
    remove_column :questions, :published
    remove_index :quiz_modules, :published
    remove_reference :quiz_modules, :created_by, foreign_key: { to_table: :users }
    remove_column :quiz_modules, :published
    remove_check_constraint :users, name: "users_role_allowed"
    remove_column :users, :role
  end
end
