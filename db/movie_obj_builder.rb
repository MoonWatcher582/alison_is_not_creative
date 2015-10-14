class Movie
	attr_reader :title
	attr_reader :year
	attr_reader :rated
	attr_reader :genres
	attr_reader :directors
	attr_reader :actors
	attr_reader :country
	attr_reader :poster
	attr_reader :type

	def build_from_data(line)
		film_info = line.split(';')
		@title = film_info[0].chomp
		@year = film_info[1].chomp
		@rated = film_info[2].chomp
		@directors = film_info[4].split(', ')
		@actors = film_info[5].split(', ')
		@country = film_info[6].chomp
		@poster = film_info[7].chomp
		parse_genres(film_info[3].split(', '), film_info[8].chomp)
	end

	def parse_genres(genres, type)
		if genres.include? 'Animation'
			if type == 'movie'
				@type = 'animated movie'
			elsif type == 'series'
				@type = 'animated series'
			else
				@type = type
			end
		else
			@type = type
		end

		@genres = genres - ['Animation']
	end
end
