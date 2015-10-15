#!/usr/bin/env bash

if [ "$1" == "-h" ]; then
	echo "USAGE: ./init_db.sh <DATABASE FILE> <SCHEMA FILE>"
	echo "Deletes the database file and rebuilds it using the schema."
	exit 0
fi

DATABASE="movies.db"
SCHEMA="schema.sql"

if [ $# -ne 2 ]; then
	echo "Database and Schema files not both provided, using default values"
else
	DATABSE="$1"
	SCHEMA="$2"
fi

rm $DATABASE && sqlite3 $DATABASE < $SCHEMA
