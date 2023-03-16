#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")

if [[ -z $USER_ID ]]
then
    #INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
else
    USER_GAMES_PLAYED=$($PSQL "SELECT count(username) FROM users WHERE username = '$USERNAME'")
    BEST_GAME=$($PSQL "SELECT min(number_of_guesses) FROM users WHERE username = '$USERNAME'")
    echo "Welcome back, $USERNAME! You have played $USER_GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

GAME() {
     #secret number
  SECRET=$((1 + $RANDOM % 1000))

  #count guesses
  TRIES=0

  #guess number
  # echo $SECRET
  GUESSED=0
  echo -e "\nGuess the secret number between 1 and 1000:"

  while [[ $GUESSED = 0 ]]; do
    read GUESS

    #if not a number
    if [[ ! $GUESS =~ ^[0-9]+$ ]]; then
      echo -e "\nThat is not an integer, guess again:"
    #if correct guess
    elif [[ $SECRET -eq $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo "You guessed it in $TRIES tries. The secret number was $SECRET. Nice job!"
      #insert into db
      INSERTED_TO_GAMES=$($PSQL "insert into users(username,number_of_guesses) values('$USERNAME', '$TRIES')")
      GUESSED=1
    #if greater
    elif [[ $SECRET -gt $GUESS ]]; then
      TRIES=$(($TRIES + 1))
      echo "It's higher than that, guess again:"
    #if smaller
    else
      TRIES=$(($TRIES + 1))
      echo "It's lower than that, guess again:"
    fi
  done
}
GAME