require 'sequel'

if ARGV.length != 1 or ARGV[0] == '-h'
	puts "USAGE: ruby db_builder_user_data.rb <user info file>"
	puts "Builds a database out of the user data"
	exist 1
end

# Constant strings
USER_COLUMNS = "name, age, country, login_name, pass_hash"
USER_TABLE = "users"

def insert_vale(value, table, column)
	DB.run "INSERT INTO #{table} (#{column}) VALUES (#{value})" if not element_exists? value, table, column
end

def element_exists?(value, table, colum)
	DB["SELECT * FROM #{table} WHERE #{column} = #{value.chomp}"].count > 0
end

DB = Sequel.connect('sqlite://users.db')

puts "Parsing and inserting from #{ARGV[0]}"
File.open(ARGV[0], 'r') do |user_info|
	user_info.each_line.with_index do |line, idx|
		user = line.chomp.split(',')
		unless user.length >= 5
			puts "#{ARGV[0]}:#{idx}: Data malformed!"
			return
		end
		user_values = "'#{user[0]}', '#{user[1]}', '#{user[2]}', '#{user[3]}', '#{user[4]}'"
	 DB.run "INSERT INTO #{USER_TABLE} (#{USER_COLUMNS}) VALUES (#{user_values})" if not element_exists? "'#{user[0]}'", USER_TABLE, "name"
	end
end	
