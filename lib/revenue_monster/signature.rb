class RevenueMonster::Signature

  def self.generate(request_body = nil, method, request_url)
    if request_body
      sorted_body = sort_body(request_body)
      replaced_body = replace_special_characters(sorted_body.to_json)
      base64_body = json_to_base64(replaced_body)
    end
    nonce = SecureRandom.alphanumeric(128)
    unix_timestamp = Time.now.to_i
    data = plain_text_parameters(base64_body, method, nonce, request_url, module_parent::SIGNATURE_TYPE, unix_timestamp)
    signature = module_parent::RSA.base64_sign(data)
    OpenStruct.new(
      signature: signature,
      nonce: nonce,
      timestamp: unix_timestamp,
      signature_type: module_parent::SIGNATURE_TYPE,
      request_url: request_url,
      method: method,
      data: @body
    )
  end

  def self.plain_text_parameters(data = nil, method, nonce, request_url, signature_type, unix_timestamp)
    str = "data=#{data}&" if data
    "#{str}method=#{method.downcase}&nonceStr=#{nonce}&requestUrl=#{request_url}&signType=#{signature_type}&timestamp=#{unix_timestamp}"
  end

  def self.replace_special_characters(str)
    str.gsub('<', '\u003c')
       .gsub('>', '\u003e')
       .gsub('&', '\u0026')
  end

  def self.json_to_base64(json)
    Base64.strict_encode64(json)
  end

  def self.sort_body(hash)
    json = hash.as_json
    # sort the above hash key alphabetically and make it compact
    json.each do |key, value|
      if value.is_a?(Hash) 
        json[key] = sort_body(value)
      end
    end
    Hash[json.sort]
  end

end