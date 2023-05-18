module FCM
  class Configuration
    attr_accessor :project_id, :base_url

    def initialize(project_id: nil, base_url: "https://fcm.googleapis.com")
      @project_id = project_id
      # drop ending slash
      @base_url = base_url.end_with?("/") ? base_url[0..-2] : base_url
    end
  end
end