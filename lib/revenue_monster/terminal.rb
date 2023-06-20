class RevenueMonster::Terminal

  def self.initiate_payment(terminal_id:, type:, order:, receipt_type: 1, camera_type: 'BACK')
    request_url = "#{module_parent.configuration.base_url}/v3/payment/terminal/quickpay"
    request_body = {
      terminalId: terminal_id,
      type: type,
      receiptType: receipt_type,
      cameraType: camera_type,
      order: order
    }
    signature = module_parent::Signature.generate(request_body, 'post', request_url)
    response = module_parent.base_request.post do |req|
      req.url request_url
      req.headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{module_parent::Authorizer.get_token.access_token}",
        'X-Signature' => "#{module_parent::SIGNATURE_TYPE} #{signature.signature}",
        'X-Nonce-Str' => signature.nonce,
        'X-Timestamp' => signature.timestamp.to_s,
      }
      req.body = request_body.to_json
    end
    
    parsed_body = JSON.parse(response.body)

    if !response.success? && parsed_body.dig('error', 'code') == 'TERMINAL_NOT_REACHABLE'
      raise module_parent::TerminalNotReachableError.new(parsed_body['error']['message']) 
    elsif !response.success?
      raise module_parent::RequestError.new(parsed_body['error']['message'])
    else
      parsed_body
    end
  rescue Faraday::TimeoutError
    raise module_parent::RequestTimeoutError
  end

  def self.cancel_payment(terminal_id:)
    request_url = "#{module_parent.configuration.base_url}/v3/event/terminal"
    request_body = { terminalId: terminal_id, type: 'CANCEL' }
    signature = module_parent::Signature.generate(request_body, 'post', request_url)
    response = module_parent.base_request.post do |req|
      req.url request_url
      req.headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{module_parent::Authorizer.get_token.access_token}",
        'X-Signature' => "#{module_parent::SIGNATURE_TYPE} #{signature.signature}",
        'X-Nonce-Str' => signature.nonce,
        'X-Timestamp' => signature.timestamp.to_s,
      }
      req.body = request_body.to_json
    end

    parsed_body = JSON.parse(response.body)

    if !response.success? && parsed_body.dig('error', 'code') == 'TERMINAL_NOT_REACHABLE'
      raise module_parent::TerminalNotReachableError.new(parsed_body['error']['message']) 
    elsif !response.success?
      raise module_parent::RequestError.new(parsed_body['error']['message'])
    else
      parsed_body
    end
  rescue Faraday::TimeoutError
    raise module_parent::RequestTimeoutError
  end

  def self.card_payment_refund(terminal_id:, transaction_id:, reason:, email:, pin:, receipt_type: 1)
    request_url = "#{module_parent.configuration.base_url}/v3/event/terminal"
    request_body = {
      terminalId: terminal_id,
      type: 'REFUND',
      data: {
        transactionId: transaction_id,
        receiptType: receipt_type,
        reason: reason,
        email: email,
        pin: pin.to_s
      }
    }
    signature = module_parent::Signature.generate(request_body, 'post', request_url)
    response = module_parent.base_request.post do |req|
      req.url request_url
      req.headers = {
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{module_parent::Authorizer.get_token.access_token}",
        'X-Signature' => "#{module_parent::SIGNATURE_TYPE} #{signature.signature}",
        'X-Nonce-Str' => signature.nonce,
        'X-Timestamp' => signature.timestamp.to_s,
      }
      req.body = request_body.to_json
    end

    parsed_body = JSON.parse(response.body)

    if !response.success? && parsed_body.dig('error', 'code') == 'TERMINAL_NOT_REACHABLE'
      raise module_parent::TerminalNotReachableError.new(parsed_body['error']['message']) 
    elsif !response.success?
      raise module_parent::RequestError.new(parsed_body['error']['message'])
    else
      parsed_body
    end
  rescue Faraday::TimeoutError
    raise module_parent::RequestTimeoutError
  end

end