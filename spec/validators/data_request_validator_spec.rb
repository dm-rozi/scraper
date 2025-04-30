require 'rails_helper'

RSpec.describe DataRequestValidator do
  let(:valid_url) { "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm" }

  context "with valid data" do
    let(:params) do
      {
        url: valid_url,
        fields: {
          title: "title",
          h1: "h1"
        }
      }
    end

    it "is valid" do
      validator = described_class.new(params)
      expect(validator.valid?).to be true
      expect(validator.errors).to be_empty
    end
  end

  context "with missing url" do
    it "is invalid" do
      validator = described_class.new({ fields: { h1: 'h1' } })
      expect(validator.valid?).to be false
      expect(validator.errors).to include("URL is required")
    end
  end

  context "with invalid url format" do
    it "is invalid" do
      validator = described_class.new({ url: 'ftp://example.com', fields: { h1: 'h1' } })
      expect(validator.valid?).to be false
      expect(validator.errors).to include("URL must be a valid http(s) address")
    end
  end

  context "with missing fields" do
    it "is invalid" do
      validator = described_class.new({ url: valid_url })
      expect(validator.valid?).to be false
      expect(validator.errors).to include("Fields must be a JSON object")
    end
  end

  context "with empty fields" do
    it "is invalid" do
      validator = described_class.new({ url: valid_url, fields: {} })
      expect(validator.valid?).to be false
      expect(validator.errors).to include("Fields cannot be empty")
    end
  end

  context "with non-hash fields" do
    it "is invalid" do
      validator = described_class.new({ url: valid_url, fields: "string" })
      expect(validator.valid?).to be false
      expect(validator.errors).to include("Fields must be a JSON object")
    end
  end

  context "with valid nested fields (array of strings)" do
    let(:params) do
      {
        url: "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
        fields: {
          meta: [ "keywords", "twitter:image" ]
        }
      }
    end

    it "is valid" do
      validator = described_class.new(params)
      expect(validator.valid?).to be true
      expect(validator.errors).to be_empty
    end
  end
end
