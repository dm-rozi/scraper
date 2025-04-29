# README

Simple rails API app. Give the link for scarapping and CSS selectors as JSON, get JSON with the values in response.


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


Curl example from Cli
```
curl 'http://localhost:3000/api/v1/data'   -G   
    --data-urlencode 'url=https://www.alza.cz/aeg-7000-prosteam-lfr73964cc-d7635493.htm'   
    --data-urlencode 'fields[price]=.price-box__primary-price__value'   
    --data-urlencode 'fields[rating_value]=.ratingValue'   
    --data-urlencode 'fields[rating_count]=.ratingCount'
```
## Installation

Database creation

Database initialization

## Running tests
```
bundle exec rspec
```
## Running Rubocop
```
bundle exec rubocop
```
