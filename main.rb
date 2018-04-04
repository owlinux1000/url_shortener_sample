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

  # TODO1: 重複検査
  # TODO2: 期間設定
  
  random_string = SecureRandom.urlsafe_base64(8)
  $redis.set(random_string, url)

  return "http://localhost:4567/" + random_string
  
end

get '/:random_string' do

  random_string = params[:random_string]
  r = $redis.get(random_string)
  
  if r.nil?
    return "Invalid url"
  end
  
  redirect to($redis.get(random_string))
  
end
