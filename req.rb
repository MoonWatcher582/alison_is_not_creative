require 'net/http'

uri = URI('http://www.omdbapi.com/')
films = ['Pulp Fiction', 'Cowboy Bebop', 'Metal Gear Solid 3: Subsistence']

fsuccess = "suc.txt"
ffail = "fail.txt"

fs = File.open(fsuccess, 'w')
ff = File.open(ffail, 'w')

films.each do |film|
	params = { :t => film }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)

	if res.is_a?(Net::HTTPSuccess)
		fs.puts res.body
	else
		ff.puts 'failed to access #{film}'
	end
end

fs.close
ff.close
