require 'rubygems'
require 'sinatra'

enable :sessions

get '/' do
	session['counter'] ||= 0
	session['counter'] += 1
	"You've hit this page #{session['counter']} times!"
end
