class CachedPage < ApplicationRecord
  CACHE_TTL = 2.hours

  validates :url, presence: true, uniqueness: true

  def expired?
    expires_at < Time.current
  end
end
