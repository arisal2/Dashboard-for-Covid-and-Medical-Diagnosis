# frozen_string_literal: true

# Sidekiq 7 configuration
# See: https://github.com/sidekiq/sidekiq/wiki/Using-Redis

Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://redis:6379/1') }

  # Load scheduled jobs
  schedule_file = Rails.root.join('config/schedule.yml')
  if File.exist?(schedule_file)
    Sidekiq::Cron::Job.load_from_hash YAML.load_file(schedule_file, permitted_classes: [Symbol])
  end
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL_SIDEKIQ', 'redis://redis:6379/1') }
end
