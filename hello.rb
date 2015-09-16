require 'sinatra'

get '/' do
	redirect '/Sinatra'
end

get '/:name' do
	name = params[:name]
	"Hello #{name}, it's #{Time.now} at the server!"
end
