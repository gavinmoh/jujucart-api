module Billplz
  class Signature
    def self.verify(params, x_signature, x_signature_key = module_parent.configuration.x_signature_key)
      hash = HashWithIndifferentAccess.new(params)

      array = if hash[:billplz].present?
                hash[:billplz].map do |key, value|
                  next if key.to_s == "x_signature"

                  "billplz#{key}#{value}"
                end
              else
                hash.map do |key, value|
                  next if key.to_s == "x_signature"

                  "#{key}#{value}"
                end
              end

      data = array.compact.sort.join("|")
      x_signature == digest(data, x_signature_key)
    end

    def self.generate(params, x_signature_key = module_parent.configuration.x_signature_key)
      hash = HashWithIndifferentAccess.new(params)
      array = hash.map do |key, value|
        "#{key}#{value}"
      end

      data = array.compact.sort.join("|")
      digest(data, x_signature_key)
    end

    def self.digest(data, x_signature_key)
      OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), x_signature_key, data)
    end
  end
end
