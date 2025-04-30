require "rails_helper"

RSpec.describe ScraperService, type: :service do
  describe '.call' do
    let(:html) { file_fixture('page_001.htm').read }
    let(:doc) { Nokogiri::HTML(html) }
    let(:url) { "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm" }
    let(:resp_double) { instance_double("Faraday::Response", body: html, status: 200) }
    let(:correct_result) {
      {
        "price" => "19 990,-",
        "rating_value" => "4,8",
        "rating_count" => "25 hodnocení"
      }
    }
    let(:result_with_errors) {
      {
        "errors" => "Selector not found: .productTitle",
        "price" => "19 990,-",
        "product_title" => nil,
        "rating_count" => "25 hodnocení",
        "rating_value" => "4,8"
      }
    }

    before do
      allow(Faraday).to receive(:get).with(url).and_return(resp_double)
    end

    subject(:result) { described_class.call(url, fields) }

    it 'calls the service with url and correct fields' do
      fields = {
        "price": ".price-box__primary-price__value",
        "rating_count": ".ratingCount",
        "rating_value": ".ratingValue"
      }

      result = ScraperService.call(url, fields)

      expect(result).to be_an_instance_of(Hash)
      expect(result).to eq(correct_result)
      expect(result).not_to have_key('errors')
    end

    it 'calls the service with url and one incorrect selector' do
      fields = {
        "price": ".price-box__primary-price__value",
        "rating_count": ".ratingCount",
        "rating_value": ".ratingValue",
        "product_title": ".productTitle"
      }
      result = ScraperService.call(url, fields)

      expect(result).to eq(result_with_errors)
    end

    it 'calls the service with url and fields with meta tag' do
      fields = { "meta": [ "keywords", "twitter:image" ] }
      result = ScraperService.call(url, fields)

      expect(result.dig("meta", "keywords")).to eq "AEG,7000,ProSteam®,LFR73964CC,Automatické pračky,Automatické pračky AEG,Chytré pračky,Chytré pračky AEG"
      expect(result.dig("meta", "twitter:image")).to eq "https://image.alza.cz/products/AEGPR065/AEGPR065.jpg?width=360&height=360"
    end
  end
end
