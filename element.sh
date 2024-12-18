

#!/bin/bash

# Set up the PSQL command with database connection
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [[ -z $1 ]]; then
  echo "Please provide an element as an argument."
  exit 1
fi

# Check if the argument is a number (atomic number)
if [[ $1 =~ ^[0-9]+$ ]]; then
  result=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING (atomic_number) WHERE atomic_number = $1;")
# Check if the argument is a symbol (one or two letters)
elif [[ $1 =~ ^[A-Za-z]{1,2}$ ]]; then
  result=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING (atomic_number) WHERE symbol = '$1';")
# Check if the argument is a name
else
  result=$($PSQL "SELECT atomic_number, symbol, name, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties INNER JOIN elements USING (atomic_number) WHERE name ILIKE '$1';")
fi

# If result is empty, element not found
if [[ -z $result ]]; then
  echo "I could not find that element in the database."
else
  # Parse the result
  IFS="|" read atomic_number symbol name atomic_mass melting_point_celsius boiling_point_celsius <<< "$result"
  
  # Format atomic_mass with 3 decimal places
  atomic_mass=$(echo $atomic_mass | awk '{printf "%.3f", $1}')
  
  echo "The element with atomic number $atomic_number is $name ($symbol). It's a nonmetal, with a mass of $atomic_mass amu. $name has a melting point of $melting_point_celsius celsius and a boiling point of $boiling_point_celsius celsius."
fi

