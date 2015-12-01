require 'sinatra/base'
require 'sinatra/reloader'
require 'sequel'
require 'haml'
require 'warden'

class User

	attr_reader :id, :name, :pass

	@@DB = Sequel.connect('sqlite://users.db')

	def initialize(id, name, pass)
		@id = id
		@name = name
		@pass = pass
	end

	def authenticate(pass)
		@pass == pass
	end

	def self.get_user_by_id(id)
		get_user("id", id)
	end

	def self.get_user_by_name(name)
		get_user("name", name)
	end

	def self.get_user(column, input)
		@@DB.fetch("SELECT id, name, pass FROM user WHERE #{column} = '#{input}'") do |row|
			user = User.new(row[:id], row[:name], row[:pass])
			return user
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
			user = User.get_user_by_name(params["user"])
			if user && user.authenticate(params["pass"])
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
		haml :home	
	end

	# make a query
	post '/query' do
		# determine which inputs we have and which queries we can make
		# make those queries
		# do shit with the query data (graphs and stuff)
		# display... somewhere
	end

	# submit review form
	get '/submission' do
		haml :submit
	end

	# submit review
	post '/review' do
		# parse review data and extract currently logged in user
		# call sql INSERT INTO
	end

	# user's page (review list)
	get '/page/:name' do |usrname|
		# get user's data from DB
		# get a list of user's reviews from DB
		haml :user_page, :locals => {:usrname => usrname}
	end

	run! if __FILE__ == $0
end
