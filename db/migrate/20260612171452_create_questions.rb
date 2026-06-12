class CreateQuestions < ActiveRecord::Migration[8.1]
  def change
    create_table :questions do |t|
      t.references :quiz_module, null: false, foreign_key: true
      t.text :body_pt
      t.text :body_en
      t.text :context_pt
      t.text :context_en
      t.integer :correct_index
      t.string :libras_video_url

      t.timestamps
    end
  end
end
