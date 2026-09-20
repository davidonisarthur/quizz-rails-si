class AddPositionsToQuestions < ActiveRecord::Migration[8.1]
  def up
    add_column :questions, :position, :integer

    execute <<~SQL.squish
      WITH numbered_questions AS (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY quiz_module_id ORDER BY id) AS new_position
        FROM questions
      )
      UPDATE questions
      SET position = numbered_questions.new_position
      FROM numbered_questions
      WHERE questions.id = numbered_questions.id
    SQL

    change_column_null :questions, :position, false
    add_index :questions, [ :quiz_module_id, :position ], unique: true
  end

  def down
    remove_index :questions, [ :quiz_module_id, :position ]
    remove_column :questions, :position
  end
end
