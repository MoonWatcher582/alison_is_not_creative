require 'bcrypt'
require 'haml'
require 'sequel'
require 'sinatra/base'
require 'sinatra/reloader'
require 'warden'
require 'pry'


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

	@@DB = Sequel.connect('sqlite://movies.db')

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

=begin
	Database and constants
=end
$DB = Sequel.connect('sqlite://movies.db')
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
		# determine which inputs we have and which queries we can make
		
		if params["director"].present? && params["actor"].present?
			#director_and_actor = $DB.fetch("SELECT CASE WHEN (SELECT AVG(r.rating) FROM movie_rating r, directed_by d, acted_in a WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND d.film_id = r.film_id AND a.film_id = d.film_id) a1 > (SELECT AVG(r.rating) FROM movie_rating r, directed_by d WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND d.film_id = r.film_id) a2 THEN 'true' ELSE 'false' END AS together;", params["director"], params["actor"], params["director"])
		end

		if params["director"].present?
			#director_by_genres = $DB.fetch("SELECT g.genre, AVG(r.rating) FROM movie_rating r, directed_by d, is_genre ig, genres g WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND r.film_id = d.film_id AND r.film_id = ig.film_id AND ig.genre_id = g.id GROUP BY ig.genre_id ORDER BY ig.genre_id;", params["director"])	
			#director_by_time = $DB.fetch("SELECT m.title, m.year, AVG(r.rating) FROM movies m, movie_rating r, directed_by d WHERE d.director_id = (SELECT id FROM directors WHERE name = ? LIMIT 1) AND m.id = d.film_id AND m.id = r.film_id GROUP BY r.film_id ORDER BY m.year;", params["director"])
		end

		if params["actor"].present?
			#actor_by_time = $DB.fetch("SELECT m.title, m.year, AVG(r.rating) FROM movies m, movie_rating r, acted_in a WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND m.id = a.film_id AND m.id = r.film_id GROUP BY r.film_id ORDER BY m.year;", params["actor"])
			#actor_by_genres = $DB.fetch("SELECT g.genre, AVG(r.rating) FROM movie_rating r, acted_in a, is_genre ig, genres g WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND r.film_id = a.film_id AND r.film_id = ig.film_id AND ig.genre_id = g.id GROUP BY ig.genre_id ORDER BY ig.genre_id;", params["actor"])
			#actor_by_country = $DB.fetch("SELECT u.country, AVG(r.rating) FROM movie_rating r, acted_in a WHERE a.actor_id = (SELECT id FROM actors WHERE name = ? LIMIT 1) AND r.film_id = a.film_id GROUP BY u.country ORDER BY u.country;", params["actor"])
		end

		if params["country"].present?
			#who_likes_our_movies = $DB.fetch("SELECT u.country, AVG(r.rating) FROM movies m, movie_rating r, users u WHERE m.country = ? AND m.id = r.film_id AND r.user_id = u.id GROUP BY u.country ORDER BY u.country;", params["country"])
			#country_good_movies = $DB.fetch("SELECT COUNT(c.a) FROM (SELECT AVG(r.rating) a FROM movies m, movie_rating r WHERE m.country = ? AND m.id = r.film_id) c WHERE c.a >= #{THRESHOLD}", params["country"])
			#country_bad_movies = $DB.fetch("SELECT COUNT(c.a) FROM (SELECT AVG(r.rating) a FROM movies m, movie_rating r WHERE m.country = ? AND m.id = r.film_id) c WHERE c.a < #{THRESHOLD}", params["country"])
		end

		if params["audience"].present?
			#genres_by_audience = $DB.fetch("SELECT g.genre, AVG(r.rating) FROM movie_rating r, genres g, is_genre ig, users u WHERE u.country = ? AND ig.genre_id = g.id AND r.film_id = ig.film_id GROUP BY r.film_id ORDER BY ig.genre_id;", params["audience"])
		end
	end

	# submit review form
	get '/submission' do
		check_authentication
		haml :submit, :locals => {msg: "", status: "success"}
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
		haml :submit, :locals => {msg: msg, status: status} 
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
		reviews = $DB.fetch("SELECT m.title, r.rating FROM movies m, movie_ratings r WHERE m.id = r.film_id AND r.user_id = ?;", id) 

		haml :user_page, :locals => {usrname: usrname, name: name, age: age, country: country, reviews: reviews}
	end

	get "/logout" do
		warden_handler.logout
		redirect "/login"
	end

	run! if __FILE__ == $0
end
