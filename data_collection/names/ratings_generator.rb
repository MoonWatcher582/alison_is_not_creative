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
users_country = Array.new
films = Array.new

# Store user names into users array.
users_f.each_line do |line|
	temp = line.split(',')
	users.push(temp[0])
	users_country.push(temp[2])
end

# Store film names into films array. 
films_f.each_line do |line|
	temp = line.split(',')
	films.push(temp[0])
end

for i in 0...users.length
	name = users[i]
	num = rand(5...50)
	index_arr = Array.new

	for k in 1..num
		k=k
		index = rand(1...films.length)
		if index_arr.include?(index) then
			next
		end			
		index_arr.push(index)
		rating = rand(2..4)

		# Skewed ratings for Quentin Tarantino.
		if (films[index] <=> "Kill Bill: Vol. 1") == 0 then
			rating = rand (4..5)
		end
		if (films[index] <=> "Death Proof") == 0 then
			rating = rand (1..2)
		end
		if (films[index] <=> "Django Unchained") == 0 then
			rating = rand (3..4)
		end
		if (films[index] <=> "Inglorious Basterds") == 0 || (films[index] <=> "Reservoir Dogs") == 0 || (films[index] <=> "Pulp Fiction") == 0 || (films[index] <=> "Jackie Brown") == 0 || (films[index] <=> "Kill Bill: Vol. 2") == 0 then
			rating = rand(2..3)
		end

		# Skewed ratings for Samuel L. Jackson
		if (films[index] <=> "The Incredibles") == 0 then
			rating = rand(4..5)
		end
		if (films[index] <=> "A Time to Kill") == 0 then
			rating = rand(1..2)
		end
			
		# Skewed ratings for Canada Produce
		if (films[index] <=> "Ace Ventura: Pet Detective") == 0 || (films[index] <=> "Ace Ventura: When Nature Calls") == 0 then
			rating = rand (4..5)
		end
		if (films[index] <=> "Bruce Almighty") == 0 
			rating = rand (1..2)
		end
		# Skewed ratings for Germany Produce
		if (films[index] <=> "Rosemarys Baby") == 0 || (films[index] <=> "Casino Royale") == 0 then
			rating = rand (1..2)
		end
		
		# Skewed ratings for Japan Audience
		if (users_country[i] <=> "Japan") == 0 then
			if (films[index] <=> "The Phantom of the Opera") == 0 then
				rating = rand (4..5)
			end
			if (films[index] <=> "A Fistful of Dollars") == 0 || (films[index] <=> "For a Few Dollars More") == 0 || (films[index] <=> "The Good the Bad and the Ugly") == 0 || (films[index] <=> "Once Upon a Time in the West") == 0 || (films[index] <=> "True Grit") == 0 then
				rating = rand (1..2)
			end
		end
		
		line = "#{name},#{films[index]},#{rating.to_s}"
		ratings_f.puts(line)
	end
end
