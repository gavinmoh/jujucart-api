class ApplicationJob < ActiveJob::Base
  # this file is required for Noticed gem
  # do not delete eventhough we are using sidekiq
  # Automatically retry jobs that encountered a deadlock
  # retry_on ActiveRecord::Deadlocked

  # Most jobs are safe to ignore if the underlying records are no longer available
  discard_on ActiveJob::DeserializationError
end
