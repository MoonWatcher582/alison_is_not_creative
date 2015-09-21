require 'net/http'

uri = URI('http://www.omdbapi.com/')
params = { :t => 'Pulp Fiction' }
uri.query = URI.encode_www_form(params)

res = Net::HTTP.get_response(uri)
puts res.body if res.is_a?(Net::HTTPSuccess)
