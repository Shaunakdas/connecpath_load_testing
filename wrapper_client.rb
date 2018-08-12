class WrapperClient
  require 'faraday'
  attr_accessor :conn,:host, :broadcast_url

  def initialize()
    # @host = 'http://13.59.133.37'
    # @host = 'http://managerconnecpath.tk/'
    @host = ENV['manager_host']
    @conn = Faraday.new(:url => @host)
  end

  def post_call(location,params)
    puts "Wrapper Service POST req" + params.to_json+@host+location
    response = @conn.post location, params
    puts "Wrapper Service POST response" + response.body
    return response
  end

end