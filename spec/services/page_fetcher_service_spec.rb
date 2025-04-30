# # before do
# #   allow(Faraday).to receive(:get).with(url).and_return(resp_double)
# # end

# spec/services/page_fetcher_service_spec.rb
require 'rails_helper'

RSpec.describe PageFetcherService, type: :service do
  let(:url) { "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm" }
  let(:html) { "<html><body>OK</body></html>" }
  let(:cached_page) do
    CachedPage.create!(
      url: url,
      html_content: html,
      fetched_at: 10.minutes.ago,
      expires_at: 5.minutes.from_now
    )
  end

  before do
    CachedPage.delete_all
  end

  context 'when cache is fresh' do
    it 'returns html from cache' do
      cached_page

      result = described_class.new(url).call
      expect(result).to be_a(PageFetcherService::FetchResult)
      expect(result.success?).to be true
      expect(result.html).to eq html
      expect(result.error).to be_nil
    end
  end

  context 'when cache is expired' do
    it 'fetches new data and replaces cache' do
      cached_page.update!(expires_at: 5.minutes.ago)

      stub_response = instance_double(Faraday::Response, status: 200, body: '<html>fresh</html>')
      allow(Faraday).to receive(:get).with(url).and_return(stub_response)

      result = described_class.new(url).call
      expect(result.success?).to be true
      expect(result.html).to eq '<html>fresh</html>'
      expect(result.error).to be_nil

      expect(CachedPage.find_by(url: url).html_content).to eq '<html>fresh</html>'
    end
  end

  context 'when server responds with 403 (blocked by bot protection)' do
    it 'returns error result with 403 status' do
      allow(Faraday).to receive(:get).with(url).and_return(
        instance_double(Faraday::Response, status: 403, body: 'Access Denied')
      )

      result = described_class.new(url).call

      expect(result.success?).to be false
      expect(result.html).to be_nil
      expect(result.error).to include('Failed to fetch data')
      expect(result.error).to include('403')
    end
  end

  context 'when remote server fails' do
    it 'returns error result' do
      allow(Faraday).to receive(:get).with(url).and_return(
        instance_double(Faraday::Response, status: 500, body: '')
      )

      result = described_class.new(url).call
      expect(result.success?).to be false
      expect(result.html).to be_nil
      expect(result.error).to include('Failed to fetch')
    end
  end

  context 'when connection fails' do
    it 'returns connection error' do
      allow(Faraday).to receive(:get).with(url).and_raise(Faraday::ConnectionFailed.new('timeout'))

      result = described_class.new(url).call
      expect(result.success?).to be false
      expect(result.error).to include('Connection error')
    end
  end
end
