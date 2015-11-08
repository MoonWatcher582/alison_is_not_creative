#!/usr/bin/env bash

if [ "$1" == "-h" ]; then
	echo "USAGE: ./pop_db.sh [flag]"
	echo "Populates the database with the hardcoded files below."
	exit 0
fi


ruby db_builder_film_data.rb csv_files/film_data.csv csv_files/genres.csv csv_files/directors.csv csv_files/actors.csv
if [ "$?" -ne 0 ]; then
	echo "Film data not populated. Please restart the database."
	exit 1
fi
echo "Successfully populated database with film data"

if [ "$#" -eq 1 ]; then
	ruby db_builder_user_data.rb csv_files/users.csv csv_files/ratings.csv
	if [ "$?" -ne 0 ]; then
		echo "User data not populated. Please restart the database."
		exit 1
	fi
	echo "Successufully populated database with user data"
fi

echo "Population successful!"
exit 0
