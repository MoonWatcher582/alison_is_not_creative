require 'sinatra'

get '/form' do
	erb :form
	# erb = embedded Ruby file
	# this will load views/form.erb 
end

post '/form' do
	"You said '#{params[:message]}'"
end

not_found do
	halt 404, 'not found'
end
