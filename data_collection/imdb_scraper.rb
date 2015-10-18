require 'net/http'
require 'json'

uri = URI('http://www.omdbapi.com/')

SOURCE = "films.txt"
SUCCESS_FILE = "film_info.txt"
FAILED_FILE = "film_not_found.txt"

success_file = File.open(SUCCESS_FILE, 'w')
failed_file = File.open(FAILED_FILE, 'w')
source_data = File.open(SOURCE, 'r')

puts "Scraping..."
source_data.each_line do |film|

	params = { :t => film }
	uri.query = URI.encode_www_form(params)
	res = Net::HTTP.get_response(uri)

	if res.is_a?(Net::HTTPSuccess)
		film_info = JSON.parse(res.body)
		if film == "\n"
			# Do nothing, empty line
		elsif film_info['Response'] == "False" 
			failed_file.puts "failed to access #{film}"
		else
			success_file.puts "#{film_info['Title']};#{film_info['Year']};"\
				"#{film_info['Rated']};#{film_info['Genre']};"\
				"#{film_info['Director']};#{film_info['Actors']};"\
				"#{film_info['Country']};#{film_info['Poster']};"\
				"#{film_info['Type']}"
		end
	else
		failed_file.puts "failed to access #{film}"
	end
end

failed_file.close

File.delete FAILED_FILE if File.zero? FAILED_FILE

success_file.close
source_data.close
