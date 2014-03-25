# -*- encoding: utf-8 -*-
require 'twitter'
require 'json'
require 'date'
require './key.rb'

@rest_client = Twitter::REST::Client.new do |config|
  config.consumer_key        = Const::CONSUMER_KEY
  config.consumer_secret     = Const::CONSUMER_SECRET
  config.access_token        = Const::ACCESS_TOKEN
  config.access_token_secret = Const::ACCESS_TOKEN_SECRET
end

@stream_client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = Const::CONSUMER_KEY
  config.consumer_secret     = Const::CONSUMER_SECRET
  config.access_token        = Const::ACCESS_TOKEN
  config.access_token_secret = Const::ACCESS_TOKEN_SECRET
end

def writeCSV(obj)
  File.open("./data/names.csv","a") do |file|
    file.write("#{obj['name']},#{obj['screen_name']},#{obj['time']},#{obj['id']}\n")
  end
end

@stream_client.user do |status|
  next unless status.is_a? Twitter::Tweet
  if !status.text.start_with? "RT" and status.text.include?("(@sasamijp)")
    name = status.text.gsub("(@sasamijp)","")
    unless name.length > 20
      @rest_client.update_profile(:name => name)
      option = {"in_reply_to_status_id" => status.id.to_s}
      tweet = "@#{status.user.screen_name} #{name}に改名しました"
      @rest_client.update tweet,option
      day = Time.now
      writeCSV({
        "name" => name.gsub(",",""),
        "screen_name" => status.user.screen_name,
        "time" => day.to_s,
        "id" => status.id.to_s
      })
    end
  end
end
