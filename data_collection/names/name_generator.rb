# Error check
if ARGV.length != 5 or ARGV[0] == '-h'
	print "USAGE:\nruby name_generator.rb <first_name_file> <last_name_file> <countries_file> <login_file> <password_file>\n"
	exit 1
end

=begin
	Opened the files passed from the command line arguments (read only - "r").
	Opened a file named "users.txt" (create and empty file for writing - "w").
=end
first_name_f = File.open(ARGV[0],"r")
last_name_f = File.open(ARGV[1], "r")
countries_f = File.open(ARGV[2], "r")
login_f = File.open(ARGV[3], "r")
pass_f = File.open(ARGV[4], "r")
users_f = File.open("users.csv", "w")

# Declared arrays to store the elements taken from the files.
first_name_arr = Array.new
last_name_arr = Array.new
countries_arr = Array.new
login_arr = Array.new
pass_arr = Array.new

# Added each element from indiviual files into arrays.
first_name_f.each_line do |line|
	first_name_arr.push(line.chomp)
end

last_name_f.each_line do |line|
	last_name_arr.push(line.chomp)
end

countries_f.each_line do |line|
	countries_arr.push(line.chomp)
end

login_f.each_line do |line|
	login_arr.push(line.chomp)
end

pass_f.each_line do |line|
	pass_arr.push(line.chomp)
end

# Shuffles the elements within each array (randomizes)
first_name_arr.shuffle!
last_name_arr.shuffle!
countries_arr.shuffle!
login_arr.shuffle!
pass_arr.shuffle!

=begin
	Concatenated the first name, last name, country and age together.
	Wrote into "users.txt"
=end
for i in 0...login_arr.length
	age = rand(18...50)
	country = rand(0...8)
	first = first_name_arr[i].downcase.capitalize
	last = last_name_arr[i].downcase.capitalize

	line = first << " " << last << "," << age.to_s << "," << countries_arr[country] << "," << login_arr[i] << "," << pass_arr[i]
	users_f.puts(line)
end

# Close files.
first_name_f.close
last_name_f.close
countries_f.close
login_f.close
pass_f.close
users_f.close
