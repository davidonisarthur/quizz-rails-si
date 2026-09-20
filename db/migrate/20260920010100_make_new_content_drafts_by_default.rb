class MakeNewContentDraftsByDefault < ActiveRecord::Migration[8.1]
  def change
    change_column_default :quiz_modules, :published, from: true, to: false
    change_column_default :questions, :published, from: true, to: false
  end
end
