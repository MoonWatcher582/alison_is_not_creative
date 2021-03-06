require 'bcrypt'
require 'mysql2'
require 'sequel'
require 'yaml'

if ARGV.length != 2 or ARGV[0] == '-h'
	puts "USAGE: ruby db_builder_user_data.rb <user info file> <ratings file>"
	puts "Builds a database out of the user data"
	exit 1
end

# Constant strings
USER_COLUMNS = "name, age, country, login_name, pass_hash"
USER_TABLE = "users"

MOVIE_TABLE = "movies"

def insert_value(value, table, column)
	DB.run "INSERT INTO #{table} (#{column}) VALUES (#{value})" if not element_exists? value, table, column
end

def element_exists?(value, table, column)
	DB["SELECT * FROM #{table} WHERE #{column} = #{value.chomp}"].count > 0
end

yamlfile = YAML.load(open('../website/config/database.yml'))
DB = Sequel.connect(database: yamlfile[:database], user: yamlfile[:username], password: yamlfile[:password], host: yamlfile[:host], port: yamlfile[:port], adapter: 'mysql2')

puts "Parsing and inserting from #{ARGV[0]}"
File.open(ARGV[0], 'r') do |user_info|
	user_info.each_line.with_index do |line, idx|
		user = line.chomp.split(',')
		unless user.length >= 5
			puts "#{ARGV[0]}:#{idx}: Data malformed!"
			return
		end
		pass = BCrypt::Password.create("#{user[4]}")
		user_values = "'#{user[0]}', '#{user[1]}', '#{user[2]}', '#{user[3]}', '#{pass}'"
	 DB.run "INSERT INTO #{USER_TABLE} (#{USER_COLUMNS}) VALUES (#{user_values})" if not element_exists? "'#{user[0]}'", USER_TABLE, "name"
	end
end

puts "Parsing and inserting from #{ARGV[1]}"
File.open(ARGV[1], 'r') do |data|
	data.each_line do |line|
		relation = line.chomp.split(',')
		DB.run "INSERT INTO movie_rating (user_id, film_id, rating) VALUES ( (SELECT m.id FROM #{USER_TABLE} m WHERE m.name = '#{relation[0]}'), (SELECT f.id FROM #{MOVIE_TABLE} f WHERE f.title = '#{relation[1]}'), #{relation[2]} )"
	end
end
