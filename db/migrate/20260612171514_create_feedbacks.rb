class CreateFeedbacks < ActiveRecord::Migration[8.1]
  def change
    create_table :feedbacks do |t|
      t.references :question, null: false, foreign_key: true
      t.string :kind
      t.text :body_pt
      t.text :body_en

      t.timestamps
    end
  end
end
