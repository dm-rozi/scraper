# README

**Simple Rails API app for scraping HTML pages**  
Send a link and a set of CSS selectors as a JSON payload — get structured data back as JSON, powered by the Nokogiri gem.

---

## ❌ Out of scope

- No frontend part.
- No authentication. (OAuth2 flow with bearer token support can be added via separate endpoints.)
- No anti-bot or scraping protection bypassing.  
  This app assumes access to protected content via partnership — for example, using a Cloudflare access token in request headers.

---

## JSON request example

```http
GET /api/v1/data

JSON body:

{
    "url": "https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm",
    "fields": {
        "price": ".price-box__price",
        "rating_count": ".ratingCount",
        "rating_value": ".ratingValue"
    }
}
```
Response:
```
{
    "price": "18290,-",
    "rating_value": "4,9",
    "rating_count": "7 hodnocení"
}
```
Example response with missing selectors:
```
{
    "errors" => "Selector not found: .productTitle",
    "price" => "19 990,-",
    "product_title" => nil,
    "rating_count" => "25 hodnocení",
    "rating_value" => "4,8"
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

Dependency - requires Ruby 3.4

```
bundle
```
Database creation, initialization

```
bundle exec rails db:create
bundle exec rails db:migrate
```

## Running tests, linter (rspec + rubocop)
```
make check
```
## Running app
```
bundle exec rails s
```
## Project structure
```
scraper/
├── app/
│   ├── controllers/
│   │   └── api/
│   │       └── v1/
│   │           └── data_controller.rb
│   ├── models/
│   │   └── cached_page.rb
│   ├── services/
│   │   ├── base_service.rb
│   │   ├── page_fetcher_service.rb
│   │   └── scraper_service.rb
│   └── validators/
│       └── data_request_validator.rb
│
├── config/
│   └── routes.rb
│
├── db/
│   ├── migrate/
│   │   └── ... create_cached_pages.rb
│   └── schema.rb
│
├── spec/
│   ├── controllers/
│   │   └── api/v1/data_controller_spec.rb
│   ├── models/
│   │   └── cached_page_spec.rb
│   ├── services/
│   │   ├── page_fetcher_service_spec.rb
│   │   └── scraper_service_spec.rb
│   └── validators/
│       └── data_request_validator_spec.rb
│
├── Makefile
├── Gemfile
├── README.md
└── ...
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