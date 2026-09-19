class AddDataIntegrityConstraints < ActiveRecord::Migration[8.1]
  def up
    change_column_null :questions, :correct_index, false
    change_column_null :quiz_attempts, :score, false
    change_column_null :feedbacks, :kind, false

    add_check_constraint :questions, "correct_index BETWEEN 0 AND 3", name: "questions_correct_index_range"
    add_check_constraint :quiz_attempts, "score >= 0", name: "quiz_attempts_nonnegative_score"
    add_index :feedbacks, [ :question_id, :kind ], unique: true

    remove_index :users, name: "index_users_on_email"
    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
  end

  def down
    remove_index :users, name: "index_users_on_lower_email"
    add_index :users, :email, unique: true

    remove_index :feedbacks, [ :question_id, :kind ]
    remove_check_constraint :quiz_attempts, name: "quiz_attempts_nonnegative_score"
    remove_check_constraint :questions, name: "questions_correct_index_range"

    change_column_null :feedbacks, :kind, true
    change_column_null :quiz_attempts, :score, true
    change_column_null :questions, :correct_index, true
  end
end
