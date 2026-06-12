class CreateOptions < ActiveRecord::Migration[8.1]
  def change
    create_table :options do |t|
      t.references :question, null: false, foreign_key: true
      t.string :text_pt
      t.string :text_en

      t.timestamps
    end
  end
end
