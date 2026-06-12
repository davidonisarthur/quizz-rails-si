class CreateQuizAttempts < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_attempts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :quiz_module, null: false, foreign_key: true
      t.integer :score

      t.timestamps
    end
  end
end
