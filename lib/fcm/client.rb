module FCM
  class Client
    def self.endpoint
      "#{module_parent.configuration.base_url}/v1/projects/#{module_parent.configuration.project_id}/messages:send"
    end

    def initialize(opt = {})
      @title       = opt[:title]
      @body        = opt[:body]
      @data        = opt[:data]
      @priority    = opt[:priority]&.downcase || 'normal'
      @token       = opt[:token]
      @badge_count = opt[:badge_count]
      @webpush_url = opt[:webpush_url]
    end

    def push(token = @token)
      raise PayloadRequiredError unless data_payload_present? or notification_payload_present?

      self.class.module_parent.base_request.post do |req|
        req.url self.class.endpoint
        req.headers = {
          'Content-Type' => 'application/json',
          'Authorization' => "Bearer #{self.class.module_parent.auth_token}"
        }
        req.body = request_body(token).to_json
      end
    end

    def notification_payload_present?
      @body.present? and @title.present?
    end

    def data_payload_present?
      @data.present?
    end

    def notification_payload
      {
        body: @body,
        title: @title
      }
    end

    def android_options
      opt = { priority: @priority == 'high' ? 'high' : 'normal' }
      return opt unless notification_payload_present?

      opt.merge({
                  notification: {
                    sound: "default",
                    default_sound: true,
                    default_vibrate_timings: true,
                    default_light_settings: true,
                    notification_priority: @priority == 'high' ? 'PRIORITY_MAX' : 'PRIORITY_DEFAULT'
                  }
                })
    end

    def apns_options
      {
        headers: {
          'apns-priority': @priority == 'high' ? '10' : '5'
        },
        payload: {
          aps: {
            sound: "default",
            badge: @badge_count || 0
          }
        }
      }
    end

    def webpush_options
      {
        fcm_options: {
          link: @webpush_url
        }
      }
    end

    def request_body(token = @token)
      body = {
        message: {
          android: android_options,
          apns: apns_options,
          token: token
        }
      }
      body[:message].merge!(notification: notification_payload) if notification_payload_present?
      body[:message].merge!(data: @data) if data_payload_present?
      body[:message].merge!(webpush: webpush_options) if @webpush_url.present?
      body
    end
  end
end
