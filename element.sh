

#!/bin/bash

# PSQL variable for querying the PostgreSQL database
PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Check if an argument is provided
if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
else
  # Check if the input is numeric (for atomic number)
  if [[ "$1" =~ ^[0-9]+$ ]]; then
    # Query by atomic number
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                     FROM elements e 
                     JOIN properties p ON e.atomic_number = p.atomic_number 
                     WHERE e.atomic_number = '$1'")

  else
    # Query by symbol or name (ILIKE for case-insensitive matching)
    ELEMENT=$($PSQL "SELECT e.atomic_number, e.symbol, e.name, p.atomic_mass, p.melting_point_celsius, p.boiling_point_celsius 
                     FROM elements e 
                     JOIN properties p ON e.atomic_number = p.atomic_number 
                     WHERE e.symbol = '$1' 
                     OR e.name ILIKE '$1'")
  fi

  # Check if the element was found
  if [[ -z "$ELEMENT" || "$ELEMENT" =~ ^\s*$ ]]; then
    echo "I could not find that element in the database."
  else
    # Trim leading/trailing spaces and format the output
    ELEMENT=$(echo "$ELEMENT" | sed 's/^[ \t]*//;s/[ \t]*$//')
    IFS="|" read -r ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$ELEMENT"
    
    # Ensure atomic_mass is formatted correctly (remove trailing zeros)
    ATOMIC_MASS=$(echo "$ATOMIC_MASS" | sed 's/\.0*$//')
    
    # Output the element information
    echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a nonmetal, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
  fi
fi

