class CreateStudyModules < ActiveRecord::Migration[8.1]
  def change
    create_table :study_modules do |t|
      t.references :created_by, null: false, foreign_key: { to_table: :users }
      t.string :title_pt, null: false
      t.string :title_en, null: false
      t.string :summary_pt, null: false
      t.string :summary_en, null: false
      t.text :content_pt, null: false
      t.text :content_en, null: false
      t.text :libras_content_pt, null: false
      t.text :libras_content_en, null: false
      t.string :video_url
      t.string :slug, null: false
      t.integer :position, null: false
      t.boolean :published, null: false, default: false
      t.timestamps
    end

    add_index :study_modules, :slug, unique: true
    add_index :study_modules, :position, unique: true
  end
end
