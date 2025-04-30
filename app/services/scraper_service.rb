class ScraperService < BaseService
  class Error < StandardError; end

  # "img" => ->(node) { node["src"].to_s.strip }
  # "a" => ->(node) { node['href'].to_s.strip }
  EXTRACTORS = {
    "meta" => ->(node) { node["content"].to_s.strip },
    "default" => ->(node) { node.text.strip }
  }.freeze

  attr_reader :url, :fields

  def initialize(url, fields)
    @url = url
    @fields = fields
    @errors = []
  end

  def call
    {}.tap do |result|
      if (html = fetch_data)
        doc = parse_html(html)
        result.merge!(build_result(doc, fields))
      end

      result["errors"] = @errors.join(", ") if @errors.any?

      Rails.logger.info("ScraperService: #{result}")
    end
  end

  private

  def fetch_data
    response = Faraday.get(url)

    if response.status != 200
      @errors << "Failed to fetch data from URL: #{url}. Response status code: #{response.status}"
      return nil
    end

    response.body
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    @errors << "Connection error: #{e.class}: #{e.message}"
    nil
  end

  def parse_html(response)
    return {} if response.nil?

    Nokogiri::HTML(response)
  end

  def build_result(doc, fields)
    fields.each_with_object({}) do |(key, spec), out|
      out[key.to_s] =
        case spec
        when Hash
          build_result(doc, spec)
        when Array
          spec.each_with_object({}) do |name_attr, group|
            selector = "meta[name='#{name_attr}']"
            group[name_attr.to_s] = safe_extract(doc, selector)
          end
        else
          safe_extract(doc, spec)
        end
    end
  end

  def safe_extract(doc, selector)
    extract_field(doc, selector)
  rescue Error => e
    @errors << e.message
    nil
  end

  def extract_field(doc, selector)
    node = doc.at_css(selector)
    raise Error, "Selector not found: #{selector}" unless node

    extractor = EXTRACTORS.fetch(node.name, EXTRACTORS["default"])
    extractor.call(node)
  end
end
