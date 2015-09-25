require "sinatra"
require "sinatra/json"
require "json"
require "open-uri"

set :protection, except: [:json_csrf]

def morph_scraper_query(scraper_name, query)
  puts "Querying morph.io scraper, #{scraper_name}, for: #{query}"
  url = "https://api.morph.io/#{scraper_name}/data.json?key=#{CGI.escape(ENV['MORPH_API_KEY'])}&query=#{CGI.escape(query)}"
  JSON.parse(open(url).read)
end

get "/vote_event/:id" do |id|
  vote_event = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'vote_events' WHERE identifier='#{id}'").first
  votes = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'votes' WHERE vote_event_id='#{id}'")

  json vote_events: [vote_event.merge(votes: votes)]
end

get "/vote_events/:date" do |date|
  vote_events = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'vote_events' WHERE date(start_date)='#{date}'")
  vote_events.map! do |ve|
    votes = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'votes' WHERE vote_event_id='#{ve["identifier"]}'")
    ve.merge(votes: votes)
  end

  json vote_events: vote_events
end
