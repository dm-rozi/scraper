class PageFetcherService < BaseService
  FetchResult = Struct.new(:html, :error) do
    def success?
      html.present?
    end
  end

  attr_reader :url

  def initialize(url)
    @url = url
    @errors = []
  end

  def call
    page = CachedPage.find_by(url: @url)

    if page&.expired?
      page.destroy
      page = nil
    end

    page ? FetchResult.new(page&.html_content, nil) : fetch_and_cache_html
  end

  private

  def fetch_and_cache_html
    response = connection

    if response.status != 200
      @errors << "Failed to fetch data from URL: #{url}. Response status code: #{response.status}"
      return FetchResult.new(nil, @errors.join(", "))
    end

    CachedPage.create!(
      url: @url,
      html_content: response.body,
      fetched_at: Time.current,
      expires_at: CachedPage::CACHE_TTL.from_now
    )

    FetchResult.new(response.body, nil)
  rescue Faraday::ConnectionFailed, Faraday::TimeoutError => e
    @errors << "Connection error: #{e.class}: #{e.message}"
    FetchResult.new(nil, @errors.join(", "))
  end

  def connection
    Faraday.get(@url)
  end
end
