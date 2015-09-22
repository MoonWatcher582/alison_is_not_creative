require 'net/http'

uri = URI('http://www.omdbapi.com/')

source = "films.txt"
fsuccess = "suc.txt"
ffail = "fail.txt"

fs = File.open(fsuccess, 'w')
ff = File.open(ffail, 'w')
sf = File.open(source, 'r')

sf.each_line do |film|

	params = { :t => film }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)

	if res.is_a?(Net::HTTPSuccess)
		fs.puts "#{film}"
	else
		ff.puts "failed to access #{film}"
	end
end

fs.close
ff.close
