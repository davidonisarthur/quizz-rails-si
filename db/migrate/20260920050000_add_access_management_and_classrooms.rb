class AddAccessManagementAndClassrooms < ActiveRecord::Migration[8.1]
  def change
    remove_check_constraint :users, name: "users_role_allowed"
    add_check_constraint :users, "role IN ('student', 'teacher', 'admin')", name: "users_role_allowed"

    create_table :teacher_access_requests do |t|
      t.references :user, null: false, foreign_key: true
      t.references :reviewed_by, foreign_key: { to_table: :users, on_delete: :nullify }
      t.string :status, null: false, default: "pending"
      t.datetime :reviewed_at
      t.timestamps
      t.check_constraint "status IN ('pending', 'approved', 'rejected')", name: "teacher_access_requests_status_allowed"
    end
    add_index :teacher_access_requests, :user_id, unique: true, where: "status = 'pending'", name: "index_teacher_requests_on_pending_user"

    create_table :teacher_invitations do |t|
      t.references :invited_by, null: false, foreign_key: { to_table: :users }
      t.string :email, null: false
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false
      t.datetime :accepted_at
      t.references :accepted_by, foreign_key: { to_table: :users, on_delete: :nullify }
      t.timestamps
    end
    add_index :teacher_invitations, :token_digest, unique: true

    create_table :classrooms do |t|
      t.references :teacher, null: false, foreign_key: { to_table: :users }
      t.string :name, null: false
      t.timestamps
    end
    create_table :classroom_enrollments do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
    add_index :classroom_enrollments, [ :classroom_id, :user_id ], unique: true

    create_table :module_assignments do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :quiz_module, null: false, foreign_key: true
      t.timestamps
    end
    add_index :module_assignments, [ :classroom_id, :quiz_module_id ], unique: true

    add_column :quiz_modules, :audience, :string, null: false, default: "public"
    add_check_constraint :quiz_modules, "audience IN ('public', 'classroom')", name: "quiz_modules_audience_allowed"
  end
end
