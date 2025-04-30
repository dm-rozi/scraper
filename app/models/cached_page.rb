class CachedPage < ApplicationRecord
  CACHE_TTL = 2.hours

  validates :url, presence: true, uniqueness: true
  validates :html_content, presence: true
  validates :fetched_at, presence: true
  validates :expires_at, presence: true

  def expired?
    expires_at < Time.current
  end
end
