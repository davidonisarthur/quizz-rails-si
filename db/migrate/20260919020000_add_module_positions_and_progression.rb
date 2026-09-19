class AddModulePositionsAndProgression < ActiveRecord::Migration[8.1]
  def up
    add_column :quiz_modules, :position, :integer
    execute "UPDATE quiz_modules SET position = id WHERE position IS NULL"
    execute <<~SQL.squish
      UPDATE quiz_modules
      SET position = CASE slug
        WHEN 'o-que-e-primo' THEN 1
        WHEN 'crivo-de-eratostenes' THEN 2
        WHEN 'primos-e-criptografia' THEN 3
        WHEN 'desafio-final' THEN 4
        ELSE position
      END,
      unlocked = (slug = 'o-que-e-primo')
    SQL
    change_column_null :quiz_modules, :position, false
    add_index :quiz_modules, :position, unique: true
  end

  def down
    remove_index :quiz_modules, :position
    remove_column :quiz_modules, :position
  end
end
