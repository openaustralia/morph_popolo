require "sinatra"
require "sinatra/json"

get "/vote_event/:id" do |id|
  json foo: id
end
