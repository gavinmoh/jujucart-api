class RevenueMonster::RSA

  def self.pkey
    OpenSSL::PKey::RSA.new(module_parent.configuration.private_key)
  end

  def self.server_pkey
    OpenSSL::PKey::RSA.new(module_parent.configuration.server_public_key)
  end

  def self.sign(data)
    pkey.sign(module_parent::SIGNATURE_TYPE, data)
  end

  def self.base64_sign(data)
    Base64.strict_encode64 sign(data)
  end

  def self.verify(data, signature)
    server_pkey.verify(module_parent::SIGNATURE_TYPE, signature, data)
  end
end