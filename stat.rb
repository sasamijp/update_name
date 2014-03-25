# -*- encoding: utf-8 -*-

require 'sinatra'
require 'open-uri'
require 'json'

helpers do

  def readdata(filename)
    s = File.read(filename, :encoding => Encoding::UTF_8)
    s = s.split("\n")
    return s
  end

end

get '/' do
  @names = readdata("./data/names.csv")
  @favorite_counts = []
  @names.each do |data|
    id = data.split(",")[3]
    html = open("http://aclog.koba789.com/api/tweets/show.json?id=#{id}").read
    json = JSON.parser.new(html)
    hash = json.parse()
    @favorite_counts.push(hash['favorites_count'])
  end
  erb :index
end
