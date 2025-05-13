#! /bin/bash

PSQL="psql -X --username=postgres --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"

#display services
DISPLAY_SERVICES(){
  echo -e "\n Available services:"
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id;")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

#main function

MAIN_MENU(){
  DISPLAY_SERVICES

  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED

  #check if the service exists
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED;")
  if [[ -z $SERVICE_NAME ]]
  then
    echo -e "\nI could not find that service. Please choose again."
    MAIN_MENU
  else
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE
    #get phone nr from customer
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE';")
    #if client does not exist
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")
    fi
    #get customer by his phone
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE';")

    echo -e "\nWhat time would you like your appointment?"
    read SERVICE_TIME

    #save the appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")
    #format the date
    SERVICE_NAME_FORMATTED=$(echo $SERVICE_NAME | sed 's/^ *//g')
    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed 's/^ *//g')
    echo -e "\nI have put you down for a $SERVICE_NAME_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."
  fi


}

MAIN_MENU