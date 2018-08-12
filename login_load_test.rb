#!/usr/bin/env ruby

require 'rubygems'
require 'json'
require 'faraday'

class WrapperClient
  attr_accessor :conn,:host, :broadcast_url, :auth

  def initialize()
    @host = 'https://manager.staging.connecpath.com/'
    @conn = Faraday.new(:url => @host)
    @auth = "eyJhbGciOiJIUzI1NiJ9.eyJhcGlfa2V5IjoiZWZmY2EwMzJlM2EwOWJmYjEzMzIwZTNkYTdhNjlkOGE0M2RiYWM0NGU5N2RiZjNlNzg5OGVmNDIyMjk4YWU0MyIsInVzZXJuYW1lIjoiZ3Vlc3QiLCJob3N0IjoiaHR0cDovLzE4LjE4OC4yMzguMjMyIiwiYWRtaW5fdXNlcm5hbWUiOiJzaGF1bmFrZGFzMjAyMCIsImFkbWluX2FwaV9rZXkiOiJlODVlODc2MDBkNzA3MjMzYzk2ZDY5MDgwZGQ5NDlhYmJiNjg5MmU3YTRhYzlkNDUyZjZjNThhMjc5OWY5Zjk5IiwiZXhwIjoxNTY1MTYyNTYxLCJpc3MiOiJpc3N1ZXJfbmFtZSIsImF1ZCI6ImNsaWVudCJ9._uE5LP5uZPDzEXlxo1_84PuaWjanoUXFQhNyCs6WfFc"

  end

  # Method for POST API Call
  def post_call(location,params)
    puts "#Wrapper Service POST req:- \n#Host: #{@host} \n#Location: #{location} \n#Params: #{params.to_json} "
    response = @conn.post location, params
    puts "#Response Code: #{response.status}"
    return response
  end

  # Method for GET API Call with auth
  def auth_get_call(location,params,auth)
    puts "#Wrapper Service GET req:- \n#Host: #{@host} \n#Location: #{location} \n#Params: #{params.to_json} "
    response =  @conn.get do |req|
      req.url location
      req.headers['Content-Type'] = 'application/json'
      req.headers['Authorization'] = auth.to_s
      req.body = params.to_json
    end
    puts "#Response Code: #{response.status}"
    return response
  end

  # Method for single Login Call
  def login_test
  	auth_params = {
      login: 'guest',
      password: 'connecpath',
      school: {admin_api_key: "e85e87600d707233c96d69080dd949abbb6892e7a4ac9d452f6c58a2799f9f99",
    		admin_username: "shaunakdas2020", code: "global"}
    }
    resp= JSON.parse(post_call('/user/login', (auth_params)).body)

    if resp.has_key?('global') && 
    	resp['global'].has_key?('api_key') && 
    	resp['global']['api_key'].has_key?('user') && 
    	resp['global']['api_key']['user'].has_key?('username')
    	puts "#Test Result: Success. Username in response:" + resp['global']['api_key']['user']['username']
    else
    	puts "#Test Result: Failure. Response:" + resp
    end
  end


  # Method for multiple Login Calls for load testing
  def login_load(count=1)
  	for i in 0..count
	    puts "#Trial #{i}"	
	    login_test
    end
  end

  def homepage_test
  	resp= JSON.parse(auth_get_call('/questions.json?id=5,6,7,8,9,10,11,12&limit=10&page=1', {}, @auth).body)

    if resp.has_key?('id_stream') && 
    	resp['id_stream'].has_key?('topic_list')
    	puts "#Test Result: Success. Question Count in response: #{resp['id_stream']['topic_list'].count}"
    else
    	puts "#Test Result: Failure. Response: #{resp}"
    end
  end

  # Method for multiple homepage Calls for load testing
  def homepage_load(count=1)
  	for i in 0..count
	    puts "#Trial #{i}"	
	    homepage_test
    end
  end

end

class Test 
  def initialize
    wrapper = WrapperClient.new()
    # wrapper.login_load(2)
    wrapper.homepage_load(2)
  end
end

# initialize object
Test.new