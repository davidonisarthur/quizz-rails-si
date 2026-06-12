class CreateQuizModules < ActiveRecord::Migration[8.1]
  def change
    create_table :quiz_modules do |t|
      t.string :title_pt
      t.string :title_en
      t.string :slug
      t.boolean :unlocked

      t.timestamps
    end
    add_index :quiz_modules, :slug, unique: true
  end
end
