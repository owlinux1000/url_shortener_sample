#!/usr/bin/env ruby
# coding: utf-8

require 'sinatra'
require 'sinatra/reloader'
require 'sinatra/json'
require 'sinatra/cross_origin'
require "securerandom"
require 'redis'
require 'logger'
require 'json'
require 'uri'

logger = Logger.new('sinatra.log')
$redis = Redis.new

options '*' do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080',
          'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST'],
          'Access-Control-Allow-Headers' => 'Content-Type'
end

before do
  headers 'Access-Control-Allow-Origin' => 'http://localhost:8080'
end

post '/add' do

  params = JSON.parse(request.body.read)
  url = params["url"]
  
  if url.nil? || url == ""
    return json({"code": 1, "message": "No url"})
  end

  logger.info(url)

  r = $redis.get(url)
  
  unless r.nil?
    return r
  end

  random_string = SecureRandom.urlsafe_base64(8)

  $redis.sadd(random_string, url)
  t = Time.now + 60*60*24*3
  $redis.sadd(random_string, t)

  json({
        "code": 0,
        "message": "success",
        "url": "http://localhost:4567/" + random_string,
        "time": t
       })
  
end

get '/:random_string' do

  random_string = params[:random_string]
  r = $redis.smembers(random_string)
  
  if r[1].nil?
    return json({"code": 1, "message": "Invalid url"})
  end
  
  if (Time.parse(r[1]) - Time.now <= 0)
    $redis.del(random_string)
    return json({"code": 1, "message": "Expired"})    
  end
  
  redirect to(r[0])
  
end
