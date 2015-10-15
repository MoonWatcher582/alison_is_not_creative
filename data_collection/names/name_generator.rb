# Error check
if ARGV.length != 2
	puts "ruby name_generator.rb <first_name_file> <last_name_file>"
	exit 1
end

=begin
	Opened the files passed from the command line arguments (read only - "r").
	Opened a file named "fullnames.txt" (create and empty file for writing - "w").
=end
first_name_f = File.open(ARGV[0],"r")
last_name_f = File.open(ARGV[1], "r")
full_name_f = File.open("fullnames.txt", "w")

# Declared arrays to store the names taken from the files.
first_name_arr = Array.new
last_name_arr = Array.new

# Added each name from first_name file into an array.
first_name_f.each_line do |line|
	first_name_arr.push(line.chomp)
end

# Added each name from last_name file into an array.
last_name_f.each_line do |line|
	last_name_arr.push(line.chomp)
end

# Shuffles the elements within each array (randomizes)
first_name_arr.shuffle!
last_name_arr.shuffle!

=begin
	Concatenated the first and last name together.
	Wrote the full name into the file "fullnames.txt"
=end
for i in 0...50
	name = first_name_arr[i] << " " << last_name_arr[i]
	full_name_f.puts(name)
end

# Close files.
first_name_f.close
last_name_f.close
full_name_f.close
