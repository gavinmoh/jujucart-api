class Current < ActiveSupport::CurrentAttributes
  attribute :request_host, :request_id, :user_agent, :ip_address
end
