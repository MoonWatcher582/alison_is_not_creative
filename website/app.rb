require 'bcrypt'
require 'google_chart'
require 'haml'
require 'mysql2'
require 'pry'
require 'rubygems'
require 'sequel'
require 'sinatra/base'
require 'sinatra/reloader'
require 'warden'
require 'yaml'

class Object
	def blank?
		respond_to?(:empty?) ? !!empty? : !self
	end

	def present?
		!blank?
	end
end

class User

	attr_reader :id, :name, :username, :pass

	yamlfile = YAML.load(open('./config/database.yml'))
	@@DB = Sequel.connect(database: yamlfile[:database], user: yamlfile[:username], password: yamlfile[:password], host: yamlfile[:host], port: yamlfile[:port], adapter: 'mysql2')

	def initialize(id, name, username)
		@id = id
		@name = name
		@username = username
	end

	def self.get_user_by_id(id)
		get_user("id", id)
	end

	def self.get_user_by_name(name)
		get_user("name", name)
	end

	def self.get_user_by_username(usrname)
		get_user("login_name", usrname)
	end

	def self.get_user(column, input)
		@@DB.fetch("SELECT id, name, login_name FROM users WHERE #{column} = ? LIMIT 1;", input) do |row|
			return User.new(row[:id], row[:name], row[:login_name])
		end
	end
end

class MyApp < Sinatra::Base

	configure :development do
		register Sinatra::Reloader
	end
	use Rack::Session::Cookie

=begin
		WARDEN HANDLING
=end
	use Warden::Manager do |manager|
		manager.default_strategies :password
		manager.failure_app = MyApp
		manager.serialize_into_session {|user| user.id}
		manager.serialize_from_session {|id| User.get_user_by_id(id)}
	end

	Warden::Manager.before_failure do |env,opts|
		env['REQUEST_METHOD'] = 'POST'
	end

	Warden::Strategies.add(:password) do
		def valid?
			params["user"] && params["pass"]
		end

		def authenticate!
			user = User.get_user_by_username(params["user"])
			if user
				success!(user)
			else	
				fail!("Could not log in")
			end
		end
	end 

	def warden_handler
		env['warden']
	end

	def check_authentication
		unless warden_handler.authenticated?
			redirect '/login'
		end
	end

	def current_user
		warden_handler.user
	end

	# Producing Graph URL
	def make_graph(info, name)
		#	test = [[0,0], [1992,3.3076923076923075], [1994,2.7777777777777777], [1997,2.8125], [2003,3.5454545454545454], [2004,2.8333333333333335], [2007,2.8181818181818183], [2009,2.76], [2012,3.4166666666666665]]
		year = Array.new()
		avg = Array.new()
		coord = Array.new()

		info.each do |item|
			year.push(item[:year].to_i)
			avg.push(item[:a].to_f)
		end

		for i in 0...year.length
			tmp = Array.new()
			tmp.push(i)
			#		tmp.push(year[i])
			tmp.push(avg[i])
			coord.push(tmp)
		end

		#	coord = [[0,0], [1,5], [2,1]]

		GoogleChart::LineChart.new('520x400', "#{name}", true) do |lcxy|
			lcxy.data "Trend", coord, '0000ff'
			lcxy.show_legend = false
			#		lcxy.axis :y, :range => [0,10]
			#    lcxy.axis :x, :range => [1992,2012]
			lcxy.grid :x_step => 100.0/6.0, :y_step => 100.0/6.0, :length_segment => 1, :length_blank => 0
			return lcxy.to_url
		end
	end

=begin
	Database and constants
=end
	yamlfile = YAML.load(open('./config/database.yml'))
	$DB = Sequel.connect(database: yamlfile[:database], user: yamlfile[:username], password: yamlfile[:password], host: yamlfile[:host], port: yamlfile[:port], adapter: 'mysql2')
	THRESHOLD = "3.5"

=begin
		ROUTES
=end
	# if warden cannot authenticate
	post '/unauthenticated' do
		redirect '/'
	end

	get '/' do
		redirect '/login'
	end

	# login + about page
	get '/login' do
		haml :login	
	end

	# login attempt
	post '/session' do
		warden_handler.authenticate!
		if warden_handler.authenticated?
			redirect '/home'
		else
			redirect '/'
		end
	end

	# home page (query form)
	get '/home' do
		check_authentication
		haml :home, :locals => {usrname: current_user.username}	
	end

	# make a query
	post '/query' do
		check_authentication

		# declare variables and initialize them to nil for Haml's sake
		director_and_actor = nil
		director_by_genres = nil
		director_by_time = nil
		actor_by_time = nil
		actor_by_genres = nil
		actor_by_country = nil
		who_likes_our_movies = nil
		num_country_good_movies = nil
		good_movies = nil
		num_country_bad_movies = nil
		bad_movies = nil
		genres_by_audience = nil
		director_graph_url = nil
		actor_graph_url = nil

		# determine which inputs we have and which queries we can make
		if params["director"].present? && params["actor"].present?
			# returns 'true' or 'false', so we can tell the user whether or not this director and actor work well together
			director_and_actor = $DB.fetch("SELECT CASE WHEN a1.a > a2.a THEN 'true' ELSE 'false' END AS t FROM (SELECT AVG(r.rating) a FROM movie_rating r, directed_by d, acted_in a WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND d.film_id = r.film_id AND a.film_id = d.film_id) a1, (SELECT AVG(r.rating) a FROM movie_rating r, directed_by d WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND d.film_id = r.film_id) a2;", params["director"], params["actor"], params["director"])
			res = director_and_actor.first 
			director_and_actor = res[:t]  == 'true' ? true : false
		end

		if params["director"].present?
			# returns genre => average rating for a director's filmography; we can show the user which of these averages are greater than the threshold, these are their strengths
			director_by_genres = $DB.fetch("SELECT g.genre, AVG(r.rating) a FROM movie_rating r, directed_by d, is_genre ig, genres g WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND r.film_id = d.film_id AND r.film_id = ig.film_id AND ig.genre_id = g.id GROUP BY ig.genre_id ORDER BY ig.genre_id;", params["director"])	
			director_by_genres.select! { |row| row[:a] >= THRESHOLD }

			# returns (movie, year) => average rating for a director's filmography; we should graph this or show it raw
			director_by_time = $DB.fetch("SELECT m.title, m.year, AVG(r.rating) a FROM movies m, movie_rating r, directed_by d WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND m.id = d.film_id AND m.id = r.film_id GROUP BY r.film_id ORDER BY m.year;", params["director"])
			director_graph_url = make_graph(director_by_time, params["director"])
		end

		if params["actor"].present?
			# returns (movie, year) => average rating for an actor's filmography; we should graph this or show it raw
			actor_by_time = $DB.fetch("SELECT m.title, m.year, AVG(r.rating) a FROM movies m, movie_rating r, acted_in a WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND m.id = a.film_id AND m.id = r.film_id GROUP BY r.film_id ORDER BY m.year;", params["actor"])
			actor_graph_url = make_graph(actor_by_time, params["actor"])

			# returns genre => average rating for an actor's filmography; we can show the user which of these averages are greater than the threshold, these are their strengths
			actor_by_genres = $DB.fetch("SELECT g.genre, AVG(r.rating) a FROM movie_rating r, acted_in a, is_genre ig, genres g WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND r.film_id = a.film_id AND r.film_id = ig.film_id AND ig.genre_id = g.id GROUP BY ig.genre_id ORDER BY ig.genre_id;", params["actor"])
			actor_by_genres.select! { |row| row[:a] >= THRESHOLD }

			# returns audience country => average rating for an actor's filmography; we can show which of these averages are greater than the threshold, these are the countries that love this actor
			actor_by_country = $DB.fetch("SELECT u.country, AVG(r.rating) a FROM movie_rating r, acted_in a, users u WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND r.film_id = a.film_id AND r.user_id = u.id GROUP BY u.country ORDER BY u.country;", params["actor"])
			actor_by_country.select! { |row| row[:a] >= THRESHOLD }
		end

		if params["country"].present?
			# returns audience => average rating for a producing country's movies; we can show which of these averages are greater than the threshold, these are the countries you should market to
			who_likes_our_movies = $DB.fetch("SELECT u.country, AVG(r.rating) a FROM movies m, movie_rating r, users u WHERE m.country = ? AND m.id = r.film_id AND r.user_id = u.id GROUP BY u.country ORDER BY u.country;", params["country"])
			who_likes_our_movies.select! { |row| row[:a] >= THRESHOLD }

			# returns the count of averages at or above the threshold for a producing country, we can compare this number with the following query to tell the user if this country generally makes good movies
			num_country_good_movies = $DB.fetch("SELECT COUNT(c.a) ct  FROM (SELECT AVG(r.rating) a FROM movies m, movie_rating r WHERE m.country = ? AND m.id = r.film_id GROUP BY m.id) c WHERE c.a >= #{THRESHOLD};", params["country"])
			good_movies = num_country_good_movies.first[:ct]

			# returns the count of averages below the threshold for a producing country, we can compare this number with the above query to tell the user if this coutry generally makes good movies
			num_country_bad_movies = $DB.fetch("SELECT COUNT(c.a) ct FROM (SELECT AVG(r.rating) a FROM movies m, movie_rating r WHERE m.country = ? AND m.id = r.film_id GROUP BY m.id) c WHERE c.a < #{THRESHOLD};", params["country"])
			bad_movies = num_country_bad_movies.first[:ct]
		end

		if params["audience"].present?
			# returns genre => average rating for an audience country; we can show which of these averages are greater than the threshold, these genres are the ones we should market to our audience
			genres_by_audience = $DB.fetch("SELECT g.genre, AVG(r.rating) a FROM movie_rating r, genres g, is_genre ig, users u WHERE u.country = ? AND ig.genre_id = g.id AND r.film_id = ig.film_id GROUP BY ig.genre_id ORDER BY ig.genre_id;", params["audience"])
			genres_by_audience.select! { |row| row[:a] >= THRESHOLD }
		end

		# massage query results so we can send them to the website

		# render website
		haml :results, :locals => {director: params["director"], actor: params["actor"], audience: params["audience"], country: params["country"], actor_graph_url: actor_graph_url, director_graph_url: director_graph_url, director_and_actor: director_and_actor, director_by_genres: director_by_genres, director_by_time: director_by_time, actor_by_time: actor_by_time, actor_by_genres: actor_by_genres, actor_by_country: actor_by_country, who_likes_our_movies: who_likes_our_movies, num_good_movies_by_country: good_movies, num_bad_movies_by_country: bad_movies, genres_by_audience: genres_by_audience}
	end

	# submit review form
	get '/submission' do
		check_authentication
		haml :submit, :locals => {msg: "", status: "success", usrname: current_user.username}
	end

	# submit review
	post '/review' do	
		check_authentication
		# parse review data and extract currently logged in user
		film_id = nil
		$DB.fetch("SELECT id FROM movies WHERE title = ? LIMIT 1;", params["movie_title"]) do |row|
			film_id = row[:id]
		end

		# call sql INSERT INTO
		msg = nil, status = nil
		if film_id == nil
			msg = "Movie not found!"
			status = "error"
		else
			$DB["INSERT INTO movie_rating VALUES(NULL, ?, ?, ?);", params["rating"], current_user.id, film_id]
			msg = "Successfully added new rating!"
			status = "success"
		end
		haml :submit, :locals => {msg: msg, status: status, usrname: current_user.username} 
	end

	# user's page (review list)
	get '/page/:name' do |usrname|
		check_authentication
		# get user's data from DB
		id = nil, name = nil, age = nil, country = nil
		$DB.fetch("SELECT id, name, age, country FROM users WHERE login_name = ? LIMIT 1;", usrname) do |row|
			id = row[:id]
			name = row[:name]
			age = row[:age]
			country = row[:country]
		end

		# get a list of user's reviews from DB
		reviews = $DB.fetch("SELECT m.title, r.rating, m.year, m.rated, m.country FROM movies m, movie_rating r WHERE m.id = r.film_id AND r.user_id = ?;", id) 

		haml :user_page, :locals => {pagename: usrname, name: name, age: age, country: country, reviews: reviews, usrname: current_user.username}
	end

	get "/logout" do
		warden_handler.logout
		redirect "/login"
	end

	run! if __FILE__ == $0
end


