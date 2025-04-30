require "rails_helper"

RSpec.describe CachedPage, type: :model do
  let(:valid_attributes) do
    {
      url: "https://example.com",
      html_content: "<html><body>cached</body></html>",
      fetched_at: Time.current,
      expires_at: 10.minutes.from_now
    }
  end

  it "is valid with valid attributes" do
    page = described_class.new(valid_attributes)
    expect(page).to be_valid
  end

  it "is invalid without a url" do
    page = described_class.new(valid_attributes.except(:url))
    expect(page).not_to be_valid
  end

  it "is invalid without html_content" do
    page = described_class.new(valid_attributes.except(:html_content))
    expect(page).not_to be_valid
  end

  it "is invalid without fetched_at" do
    page = described_class.new(valid_attributes.except(:fetched_at))
    expect(page).not_to be_valid
  end

  it "is invalid without expires_at" do
    page = described_class.new(valid_attributes.except(:expires_at))
    expect(page).not_to be_valid
  end

  describe "#expired?" do
    it "returns true when expired" do
      page = described_class.new(valid_attributes.merge(expires_at: 1.minute.ago))
      expect(page.expired?).to be true
    end

    it "returns false when not expired" do
      page = described_class.new(valid_attributes.merge(expires_at: 10.minutes.from_now))
      expect(page.expired?).to be false
    end
  end
end
