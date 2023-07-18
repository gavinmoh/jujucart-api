module Billplz
  class Bill
    Bill = Struct.new(
      :id, :collection_id, :paid, :state, :amount, :paid_amount, :due_at, :email,
      :mobile, :name, :url, :reference_1_label, :reference_1, :reference_2_label,
      :reference_2, :redirect_url, :callback_url, :description
    )

    def self.create(collection_id, email, mobile, name, amount, callback_url, description, optional = {})
      response = module_parent.base_request.post("/api/v3/bills") do |req|
        req.body = {
          collection_id: collection_id,
          description: description,
          amount: amount,
          mobile: mobile,
          email: email,
          name: name,
          callback_url: callback_url
        }.merge(optional).to_json
      end
      raise StandardError, "#{response.status}: #{response.body}" if response.status != 200

      parse_bill(response.body)
    end

    def self.get(id)
      response = module_parent.base_request.get("/api/v3/bills/#{id}")
      raise StandardError, "#{response.status}: #{response.body}" if response.status != 200

      parse_bill(response.body)
    end

    def self.delete(id)
      response = module_parent.base_request.delete("/api/v3/bills/#{id}")
      raise StandardError, "#{response.status}: #{response.body}" if response.status != 200

      true
    end

    def self.get_url(id)
      parsed = URI.parse(module_parent.configuration.base_url)
      "#{parsed.scheme}://#{parsed.host}/bills/#{id}"
    end

    def self.parse_bill(response)
      parsed = response.is_a?(Hash) ? response : JSON.parse(response)
      Bill.new(
        parsed['id'],
        parsed['collection_id'],
        parsed['paid'],
        parsed['state'],
        parsed['amount'],
        parsed['paid_amount'],
        parsed['due_at'],
        parsed['email'],
        parsed['mobile'],
        parsed['name'],
        parsed['url'],
        parsed['reference_1_label'],
        parsed['reference_1'],
        parsed['reference_2_label'],
        parsed['reference_2'],
        parsed['redirect_url'],
        parsed['callback_url'],
        parsed['description']
      )
    end
  end
end
