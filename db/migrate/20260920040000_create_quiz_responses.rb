class CreateQuizResponses < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_responses do |t|
      t.references :quiz_attempt, null: false, foreign_key: true
      t.references :question, foreign_key: { on_delete: :nullify }
      t.integer :selected_index, null: false
      t.boolean :correct, null: false

      t.timestamps
      t.check_constraint "selected_index BETWEEN 0 AND 3", name: "quiz_responses_selected_index_range"
    end

    add_index :quiz_responses, [ :quiz_attempt_id, :question_id ], unique: true
  end
end
