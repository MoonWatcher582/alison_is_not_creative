require 'sequel'
require_relative 'movie'

if ARGV.length != 1
	puts "ruby db_builder.rb <film info file>"
	exit 1
end

#	Open input file and database connection
#	sqlite3 and sequel gems required, as well as yum's sqlite3-devel
film_info = File.open(ARGV[0], 'r')
DB = Sequel.connect('sqlite://movies.db')

=begin
			Look at each line in the file and create a movie object
			Add an entry to movies, actors, directors table
			Create a relational entry in directed_by, acted_in tables
=end
film_info.each_line do |line|
	movie = Movie.build_from_data line
	puts movie.title
end
