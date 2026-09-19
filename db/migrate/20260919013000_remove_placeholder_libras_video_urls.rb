class RemovePlaceholderLibrasVideoUrls < ActiveRecord::Migration[8.1]
  PLACEHOLDER_URL = "https://www.youtube.com/watch?v=dQw4w9WgXcQ".freeze

  def up
    execute <<~SQL.squish
      UPDATE questions
      SET libras_video_url = NULL
      WHERE libras_video_url = #{connection.quote(PLACEHOLDER_URL)}
    SQL
  end

  def down
    # Never restore placeholder content that was presented as LIBRAS material.
  end
end
