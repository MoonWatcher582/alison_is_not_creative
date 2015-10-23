# Error check
if ARGV.length != 3
	print "FOLLOW THIS FORMAT:\nruby namegenerator.rb <first_name_file> <last_name_file> <countries_file>\n"
	exit 1
end

=begin
	Opened the files passed from the command line arguments (read only - "r").
	Opened a file named "fullnames.txt" (create and empty file for writing - "w").
=end
first_name_f = File.open(ARGV[0],"r")
last_name_f = File.open(ARGV[1], "r")
countries_f = File.open(ARGV[2], "r")
#genres_f = File.open(ARGV[3], "r")
users_f = File.open("users.txt", "w")

# Declared arrays to store the elements taken from the files.
first_name_arr = Array.new
last_name_arr = Array.new
countries_arr = Array.new
#genres_arr = Array.new

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

=begin
genres_f.each_line do |line|
	genres_arr.push(line.chomp)
end
=end

# Shuffles the elements within each array (randomizes)
first_name_arr.shuffle!
last_name_arr.shuffle!
countries_arr.shuffle!
#genres_arr.shuffle!

=begin
	Concatenated the first and last name together.
	Wrote the full name into the file "fullnames.txt"
=end
j = 0;
k = 0;
for i in 0...first_name_arr.length
	numgenres = rand(1...4)
	age = rand(18...50)
	
	if j == countries_arr.length
		countries_arr.shuffle!
		j = 0;
	end
	
	line = first_name_arr[i] << " " << last_name_arr[i] << "," << countries_arr[j] << "," << age.to_s #<< ";"
	
	for n in 1..numgenres
		if n == numgenres
			#line = line << genres_arr[k]
		else
			#line = line << genres_arr[k] << ","
		end
		# puts(line)
		k+=1
	end
	genres_arr.shuffle!
	users_f.puts(line)
	j+=1;
end

# Close files.
first_name_f.close
last_name_f.close
countries_f.close
users_f.close
