namespace :access do
  desc "Grant a production role. Requires TARGET_EMAIL and TARGET_ROLE=admin or teacher."
  task grant_role: :environment do
    abort "This task can only run in production." unless Rails.env.production?

    email = ENV.fetch("TARGET_EMAIL").strip.downcase
    role = ENV.fetch("TARGET_ROLE")
    abort "TARGET_ROLE must be admin or teacher." unless %w[admin teacher].include?(role)

    User.find_by!(email: email).update!(role: role)
    puts "Role granted to #{email}."
  end
end
