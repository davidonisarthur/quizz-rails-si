class AddStudyProgressAndQuizLinks < ActiveRecord::Migration[8.1]
  def change
    add_reference :study_modules, :quiz_module, foreign_key: { on_delete: :nullify }

    create_table :study_progresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :study_slug, null: false
      t.datetime :started_at, null: false
      t.datetime :last_accessed_at, null: false
      t.datetime :completed_at
      t.timestamps
    end

    add_index :study_progresses, [ :user_id, :study_slug ], unique: true
  end
end
