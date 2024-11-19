#! /bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e '\n*** The Chop Shop ***\n'

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  #call services
  echo "How may I help you?"
  SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo "4) EXIT"

  read SERVICE_ID_SELECTED
  #if service_input is not listed
  if [[ $SERVICE_ID_SELECTED != 1 && $SERVICE_ID_SELECTED != 2 && $SERVICE_ID_SELECTED != 3 && $SERVICE_ID_SELECTED != 4 ]]
  then
    MAIN_MENU "Please enter a valid option."
  else
    #ask phone number
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_RESULT=$($PSQL "SELECT phone FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #if not in customers table ask for name
      if [[ -z $CUSTOMER_PHONE_RESULT ]]
      then
      echo -e "\nI cannot seem to find your phone number in our database, what's your name?"
      read CUSTOMER_NAME
      #add phone and name to customers table
      ADD_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
      echo -e "\nYour details have been added succesfully." 
      fi
    #ask for appointment time
    echo -e "\nAt what time would you like your appointment ?"
    read SERVICE_TIME
    #get customer ID
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    #schedule appointment
    INSERT_APP_1=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    #customer confirmation
    CSERVICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    echo -e "\nI have put you down for a $CSERVICE at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
  }

MAIN_MENU

