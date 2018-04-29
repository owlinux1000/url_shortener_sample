#!/usr/bin/env ruby
# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require "securerandom"
require 'redis'
require 'logger'

logger = Logger.new('sinatra.log')
$redis = Redis.new

post '/' do
  
  url = params[:url]
  if url.nil? || url == ""
    return "No url"
  end
  
  logger.info(url)

  r = $redis.get(url)
  unless r.nil?
    return r
  end

  random_string = SecureRandom.urlsafe_base64(8)

  $redis.sadd(random_string, url)
  $redis.sadd(random_string, Time.now + 60*60*24*3)
  return "http://localhost:4567/" + random_string
  
end

get '/:random_string' do

  random_string = params[:random_string]
  r = $redis.smembers(random_string)
  
  if r[1].nil?
    return "Invalid url"
  end
  
  if (r[0] - Time.now <= 0)
    $redis.del(random_string)
    return "Expired"
  end
  
  redirect to($redis.get(random_string))
  
end
