class ScraperService < BaseService
  class Error < StandardError; end

  attr_reader :url, :fields

  def initialize(url, fields)
    @url = url
    @fields = fields
    @errors = []
  end

  def call
    response = fetch_data
    result = parse_data(response)

    result["errors"] = @errors.join(", ") if @errors.any?
    Rails.logger.info("ScraperService: #{result}")

    result
  end

  private

  def fetch_data
    response = Faraday.get(url)

    @errors << "Failed to fetch data from URL: #{url}. Response status code: #{response.status}" if response.status != 200

    response.body
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    @errors << "Connection error: #{e.class}: #{e.message}"
    nil
  end

  def parse_data(response)
    return {} if response.nil?

    doc = Nokogiri::HTML(response)
    result = {}

    fields.each do |key, selector|
      element = doc.at_css(selector)
      result[key] = element ? element.text.strip : nil
    end

    result
  rescue StandardError => e
    @errors << "Failed to parse data: #{e.message}"
  end
end
