require 'net/http'

uri = URI('http://www.omdbapi.com/')

source = "films.txt"
fsuccess = "suc.txt"
ffail = "fail.txt"

fs = File.open(fsuccess, 'w')
ff = File.open(ffail, 'w')
sf = File.open(source, 'r')

sf.each_line do |line|
	line_split = line.split(',')
	film = line_split[0]
	type = line_split[1].chomp

	params = { :t => film }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)

	if res.is_a?(Net::HTTPSuccess)
		fs.puts "#{film}"
		case type
		when "f"
			fs.puts "\tfilm"
		when "af"
			fs.puts "\tanimated film"
		when "ls"
			fs.puts "\tlive series"
		when "as"
			fs.puts "\tanimated series"
		when "vg"
			fs.puts "\tvideo game"
		else
			fs.puts "\tWRONG"
		end
	else
		ff.puts "failed to access #{film}"
	end
end

fs.close
ff.close
