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

	def initialize(title, year, rated, genres, directors, actors, country, poster, type)
		@title = title
		@year = year
		@rated = rated
		@genres = genres
		@directors = directors
		@actors = actors
		@country = country
		@poster = poster
		@type = type
	end

	def self.build_from_data(line)
		film_info = line.split(';')
		title = film_info[0].chomp
		year = film_info[1].chomp
		rated = film_info[2].chomp
		directors = film_info[4].split(', ')
		actors = film_info[5].split(', ')
		country = film_info[6].chomp
		poster = film_info[7].chomp
		genres, type = parse_genres(film_info[3].split(', '), film_info[8].chomp)
		return Movie.new(title, year, rated, genres, directors, actors, country, poster, type)
	end

	def self.parse_genres(genres, type)
		if genres.include? 'Animation'
			if type == 'movie'
				f_type = 'animated movie'
			elsif type == 'series'
				f_type = 'animated series'
			else
				f_type = type
			end
		else
			f_type = type
		end

		f_genres = genres - ['Animation']
		return f_genres, f_type
	end
end
