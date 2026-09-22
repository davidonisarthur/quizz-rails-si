class AddContentVisibilityAndPlatformDefaults < ActiveRecord::Migration[8.1]
  DEFAULT_QUIZ_SLUGS = %w[
    o-que-e-primo
    crivo-de-eratostenes
    primos-e-criptografia
    desafio-final
  ].freeze

  def up
    add_column :quiz_modules, :platform_default, :boolean, null: false, default: false
    add_column :study_modules, :platform_default, :boolean, null: false, default: false
    add_column :study_modules, :audience, :string, null: false, default: "public"
    add_check_constraint :study_modules, "audience IN ('public', 'classroom')", name: "study_modules_audience_allowed"

    create_table :study_module_assignments do |t|
      t.references :classroom, null: false, foreign_key: true
      t.references :study_module, null: false, foreign_key: true
      t.timestamps
    end
    add_index :study_module_assignments, [ :classroom_id, :study_module_id ], unique: true, name: "index_study_assignments_on_classroom_and_module"

    execute <<~SQL.squish
      UPDATE quiz_modules
      SET platform_default = TRUE, audience = 'public'
      WHERE slug IN (#{DEFAULT_QUIZ_SLUGS.map { |slug| connection.quote(slug) }.join(', ')})
    SQL
  end

  def down
    drop_table :study_module_assignments
    remove_check_constraint :study_modules, name: "study_modules_audience_allowed"
    remove_column :study_modules, :audience
    remove_column :study_modules, :platform_default
    remove_column :quiz_modules, :platform_default
  end
end
