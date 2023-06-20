module CallbackLoggable
  extend ActiveSupport::Concern

  included do
    before_action :log_callback, only: [:callback]
    after_action :mark_callback_as_processed, only: [:callback]
  end

  private
    def log_callback
      request_headers = request.env.select {|k, _v| k =~ /^HTTP_/}
      @callback = CallbackLog.create(
        request_headers: request_headers,
        request_body: request.body.read,
        callback_from: @callback_from
      )
    end

    def mark_callback_as_processed
      @callback.update(processed_at: @callback_processed_at) if @callback_processed_at.present?
    end
end
