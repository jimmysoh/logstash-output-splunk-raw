require "logstash/outputs/base"
require "logstash/namespace"

class LogStash::Outputs::SplunkRaw < LogStash::Outputs::Base
  config_name "splunk-raw"
  milestone 1

  # HEC endpoint URL
  config :url, :validate => :string, :required => true

  # HEC token
  config :token, :validate => :string, :required => true

  # Event encoding
  config :encoding, :validate => :string, :default => "utf-8"

  public
  def register
    # set up any initialization required for the plugin
  end # def register

  public
  def receive(event)
    # Construct the HEC request
    begin
      uri = URI.parse(@url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = "Splunk #{@token}"
      request["Content-Type"] = "text/plain"
      request.body = event.get("message")

      # Send the HEC request
      response = http.request(request)

      # Check the response status code
      if response.code != "200"
        @logger.error("Failed to send event to Splunk HEC, response code: #{response.code}")
      end
    rescue => e
      @logger.error("Failed to send event to Splunk HEC: #{e}")
    end
  end # def receive

  public
  def close
    # tear down any resources the plugin may have created
  end # def close
end # class LogStash::Outputs::SplunkRaw
