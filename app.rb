require "sinatra/base"
require "sinatra/json"
require "pry"
require "json"

DB = {}

class Coloson < Sinatra::Base
  set :logging, true
  set :show_exceptions, false

  error do |e|
    raise e
  end

  def self.reset_database
    DB.clear
  end

  get "/numbers/:collection" do
    json get_collection
  end

  post "/numbers/:collection" do
    if is_valid_number? params[:number]
      get_collection.push params[:number].to_i
      body "ok"
    else
      status 422
      json(
        status: "error",
        error: "Invalid number: #{params[:number]}"
      )
    end
  end

  delete "/numbers/:collection" do
    number = params[:number].to_i

    get_collection.delete number

    body "ok"
  end

  get "/numbers/:collection/sum" do
    sum = get_collection.reduce 0, :+
    json(
      status: "ok",
      sum:    sum
    )
  end

  get "/numbers/:collection/product" do
    prod = get_collection.reduce 1, :*
    if prod > 1_000
      status 422
      json status: "error", error: "Only paid users can multiply numbers that large"
    else
      json status: "ok", product: prod
    end
  end

  def get_collection
    DB[ params[:collection] ] ||= []
    DB[ params[:collection] ]
  end

  def is_valid_number? string
    string.to_i.to_s == string
  end
end

Coloson.run! if $PROGRAM_NAME == __FILE__
