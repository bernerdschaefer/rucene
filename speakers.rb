require 'rubygems'

require 'net/http'
require 'json'
require 'sinatra/base'
require 'haml'

require 'rucene'
Rucene.run! :port => 9091

class Speakers < Sinatra::Base
  set :current_index, 1

  get '/' do
    query = {}
    query.merge!(
      "field" => params["field"],
      "term" => params["term"]
    ) if params["field"]

    Net::HTTP.start("localhost", 9091) do |http|
      response = http.send_request(
        'GET', '/speakers', query.to_json)
      @speakers = JSON.parse(response.body)["results"]
    end

    haml :index
  end

  post '/' do
    settings.current_index = params["id"].to_i

    Net::HTTP.start("localhost", 9091) do |http|
      http.post("/speakers", params.to_json)
    end

    redirect '/'
  end
end

Speakers.run! :port => 9092
