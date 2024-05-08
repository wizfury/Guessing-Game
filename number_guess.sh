#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c" 

#generate random number
NUMBER=$((1+RANDOM%1000))
COUNT=$((0))

MAIN_MENU()
{
  #get username
  echo "Enter your username:"
  read USERNAME
  
  USERDETAILS=$($PSQL "SELECT * FROM users FULL JOIN games USING(user_id) WHERE username='$USERNAME'")
  

  #if not found
  if [[ -z $USERDETAILS ]];
  then
    
    echo "Welcome, $USERNAME! It looks like this is your first time here."

    #insert new user to database
    INSERT_USER=$($PSQL "INSERT INTO users(username) VALUES('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    ADD_FIRST_GAME=$($PSQL "INSERT INTO games(user_id) VALUES($USER_ID)")
    
  
  #if found
  else
    echo "$USERDETAILS" | while IFS="|" read USERID USERNAME GAMES_PLAYED BEST_GAME
    do
      echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses." 
    done
  fi 

  echo "Guess the secret number between 1 and 1000:"
  #test
  # echo "$NUMBER" 
  GAME

}
GAME()
{
  #if arg
  if [[ ! -z $1 ]];
  then
    echo $1
  fi

  #take input
  read GUESS
  
  
  #if the guess is not number
  if [[ ! $GUESS =~ [0-9]+ ]];
  then

    GAME "That is not an integer, guess again:"
  else
    #if guess higher than number
    if [[ $GUESS -gt $NUMBER ]];
    then
      (( COUNT+=1 ))
      GAME "It's lower than that, guess again:"

    #if guess less than number
    elif [[ $GUESS -lt $NUMBER ]];
    then
      (( COUNT+=1 ))
      GAME "It's higher than that, guess again:"

    #if Guessed
    else
      (( COUNT+=1 ))
      echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"

      #check if the user score is greater than best score
      USERDETAILS=$($PSQL "SELECT * FROM users FULL JOIN games USING(user_id) WHERE username='$USERNAME'") 
      echo "$USERDETAILS" | while IFS="|" read USERID USERNAME GAMES_PLAYED BEST_GAME
      do

        #update the games count
        (( GAMES_PLAYED+=1 ))

        #if the count less than best score
        if [[ $COUNT -lt $BEST_GAME ]];
        then
          #update the count with best score
          UPDATE_BEST_GAME=$($PSQL "UPDATE games SET best_games='$COUNT' WHERE user_id='$USERID'")
          #update the number of games
          UPDATE_GAMES_PLAYED=$($PSQL "UPDATE games SET games_played='$GAMES_PLAYED' WHERE user_id='$USERID'")
        fi
      done

    fi

  fi

}

MAIN_MENU