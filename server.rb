require "sinatra"
require "sinatra/json"
require "json"
require "open-uri"

set :protection, except: [:json_csrf]

use Rack::Deflater

def morph_scraper_query(scraper_name, query)
  puts "Querying morph.io scraper, #{scraper_name}, for: #{query}"
  url = "https://api.morph.io/#{scraper_name}/data.json?key=#{CGI.escape(ENV['MORPH_API_KEY'])}&query=#{CGI.escape(query)}"
  JSON.parse(open(url).read)
end

# Nests source_url and debate_url under the Popolo sources array
def nest_sources(h)
  h[:sources] = [
    {url: h.delete("source_url"), note: "Source URL"},
    {url: h.delete("debate_url"), note: "Debate URL"}
  ]

  h
end

get "/vote_event/:id" do |id|
  vote_event = nest_sources(morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'vote_events' WHERE identifier='#{id}'").first)
  votes = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'votes' WHERE vote_event_id='#{id}'")
  bills = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'bills' WHERE vote_event_id='#{id}'")

  json vote_events: [vote_event.merge(votes: votes, bills: bills)]
end

get "/vote_events/:date" do |date|
  vote_events = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'vote_events' WHERE date(start_date)='#{date}'")
  vote_event_ids = vote_events.map { |ve| "'#{ve["identifier"]}'" }.join(", ")
  all_bills = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'bills' WHERE vote_event_id IN (#{vote_event_ids})")
  all_votes = morph_scraper_query(ENV["MORPH_SCRAPER_NAME"], "SELECT * FROM 'votes' WHERE vote_event_id IN (#{vote_event_ids})")

  vote_events.map! do |ve|
    votes = all_votes.select { |v| v["vote_event_id"] == ve["identifier"] }
    bills = all_bills.select { |v| v["vote_event_id"] == ve["identifier"] }
    nest_sources(ve).merge(votes: votes, bills: bills)
  end

  json vote_events: vote_events
end
