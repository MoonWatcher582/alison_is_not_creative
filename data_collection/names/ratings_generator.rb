# Error check.
if ARGV.length != 2 or ARGV[0] =='-h'
	print "USAGE:\nruby ratings_generator.rb <users_csv> <films_csv>\n"
	exit 1
end

# Open files
users_f = File.open(ARGV[0], "r")
films_f = File.open(ARGV[1], "r")
ratings_f = File.open("ratings.csv", "w")

# Declare arrays to store users and films.
users = Array.new
films = Array.new

# Store user names into users array.
users_f.each_line do |line|
	temp = line.split(',')
	users.push(temp[0])
end

# Store film names into films arary. 
films_f.each_line do |line|
	temp = line.split(',')
	films.push(temp[0])
end

ratings_f.puts("user,movie,rating")
for i in 1...users.length
	name = users[i]
	num = rand(1...6)
	index_arr = Array.new

	for k in 1..num
		k=k
		index = rand(1...films.length)
		if index_arr.include?(index) then
			next
		end			
		index_arr.push(index)
		rating = rand(1..6)
		line = "#{name},#{films[index]},#{rating.to_s}"
		ratings_f.puts(line)
	end
end
