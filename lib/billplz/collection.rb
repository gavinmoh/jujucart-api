module Billplz
  class Collection
    Collection = Struct.new(:id, :title, :logo, :split_payment, :status)
    Collections = Struct.new(:data, :page)

    def self.list(opt = {})
      page = opt[:page] || 1

      response = module_parent.base_request.get("/api/v3/collections") do |req|
        req.params['page'] = page
      end

      parse_collections(response.body)
    end

    def self.create(title)
      response = module_parent.base_request.post("/api/v3/collections") do |req|
        req.body = {
          title: title
        }.to_json
      end
      parse_collection(response.body)
    end

    def self.get(id)
      response = module_parent.base_request.get("/api/v3/collections/#{id}")
      parse_collection(response.body)
    end

    def self.parse_collections(response)
      parsed = JSON.parse(response.body)
      Collections.new(
        parsed['collections'].map { |collection| parse_collection(collection) },
        parsed['page'].to_i
      )
    end

    def self.parse_collection(response)
      parsed = response.is_a?(Hash) ? response : JSON.parse(response)
      Collection.new(
        parsed['id'],
        parsed['title'],
        parsed['logo'],
        parsed['split_payment'],
        parsed['status']
      )
    end
  end
end
