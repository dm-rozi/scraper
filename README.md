# README

Simple rails API app. Give the link for scarapping and CSS selectors as JSON, get JSON with the values in response using Nokogiri gem.


Out of scope:

* No any frontend part
* No any auth features. It could be seperate endpoints for Oauth 2 flow with getting bearer access token.
* No handling any scraping protection. I suppose this is a partnership service and it has the Cloudfare access token in the header for each request.
----

JSON Request example:
```
GET /data

JSON params:

    {
        "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
        "fields": {
            "price": ".price-box__price",
            "rating_count": ".ratingCount",
            "rating_value": ".ratingValue"
        }
    }

Response:

    {
        "price": "18290,-",
        "rating_value": "4,9",
        "rating_count": "7 hodnocení"
    }
```


Curl example from Cli for the local app instance
```
curl -X GET http://localhost:3000/api/v1/data \
  -H "Content-Type: application/json" \
  -d '{
    "url": "https://nokogiri.org/",
    "fields": {
      "title": "title",
      "main_header": "h1"
    }
  }'

```
Response
```
{   
    "title":"Nokogiri",
    "main_header":"Nokogiri¶"
}
```
## Installation
Dependency - Ruby 3.4

```
bundle
```

Database creation, initialization

```
bundle exec rails db:create
bundle exec rails db:migrate
```

## Running rspec + rubocop
```
make check
```
## Running Rubocop
```
bundle exec rubocop
```
## Running app
```
bundle exec rails s
```
## Make check report
```
bundle exec rspec

Randomized with seed 23903

DataRequestValidator
  with invalid url format
    is invalid
  with missing fields
    is invalid
  with non-hash fields
    is invalid
  with valid nested fields (array of strings)
    is valid
  with valid data
    is valid
  with missing url
    is invalid
  with empty fields
    is invalid

CachedPage
  is invalid without fetched_at
  is invalid without a url
  is invalid without expires_at
  is invalid without html_content
  is valid with valid attributes
  #expired?
    returns false when not expired
    returns true when expired

ScraperService
  .call
    calls the service with meta tag fields
    calls the service with correct fields
    calls the service with one incorrect selector

PageFetcherService
  when server responds with 403 (blocked by bot protection)
    returns error result with 403 status
  when remote server fails
    returns error result
  when cache is fresh
    returns html from cache
  when cache is expired
    fetches new data and replaces cache
  when connection fails
    returns connection error

Finished in 0.08759 seconds (files took 0.67951 seconds to load)
22 examples, 0 failures

Randomized with seed 23903

bundle exec rubocop
Inspecting 33 files
.................................

33 files inspected, no offenses detected
```