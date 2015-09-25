# morph_popolo

A little Sinatra app to output Popolo data from the morph.io API. It currently only supports vote data.

## Usage

First, install Gem dependencies with the `bundle` command.

The server expects two environment variables, `MORPH_API_KEY` and `MORPH_SCRAPER_NAME`.

`MORPH_API_KEY` is your key from http://morph.io/api

`MORPH_SCRAPER_NAME` is the name of the scraper we're extracting data from. This was built against a [specific scraper](https://morph.io/openaustralia/ukraine_verkhovna_rada_votes) so you'll want to be scraping data in a similar format.

Then you can run it with:

    MORPH_API_KEY=my_sekret_key MORPH_SCRAPER_NAME=openaustralia/ukraine_verkhovna_rada_votes be bundle exec rackup

Given the `identifier` of the `vote_event` you want is "3106" you'll be able to access Popolo vote data at:

http://localhost:9292/vote_event/3106

You can also get all votes on a day:

http://localhost:9292/vote_events/2015-07-14

## Deployment

Deploy it to Heroku:

    heroku create
    heroku config:set MORPH_API_KEY=my_sekret_key MORPH_SCRAPER_NAME=openaustralia/ukraine_verkhovna_rada_votes
    git push heroku master
    heroku open

Then in your browser you'll need to append the right path to your opened app. Something like:

https://arcane-mountain-8284.herokuapp.com/vote_event/3106
