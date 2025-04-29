require "rails_helper"

RSpec.describe ScraperService, type: :service do
  describe '.call' do
    let(:html) { file_fixture('page_001.htm').read }
    let(:doc)  { Nokogiri::HTML(html) }
    let(:url)    { "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm" }
    let(:fields) {
      {
        "price": ".price-box__primary-price__value",
        "rating_count": ".ratingCount",
        "rating_value": ".ratingValue",
        "product_title": ".productTitle"
      }
    }
    let(:expected_result) {
      {
        "price": "19 990,-",
        "rating_value": "4,8",
        "rating_count": "25 hodnocení",
        "product_title": nil
      }
    }
    let(:response_double) do
      instance_double(
        "Faraday::Response",
        body: html,
        status: 200,
      )
    end

    it 'calls the service with url and fields' do
      allow(Faraday).to receive(:get).with(url).and_return(response_double)

      result = ScraperService.call(url, fields)

      expect(result).to be_an_instance_of(Hash)
      expect(result).to include(expected_result)
    end
  end
end
