#! /bin/bash
#Scheduler for creating appointments in a salon

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Welcome to Salon X cut ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  echo -e "How may I help you?\n" 
  
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
    
  if [[ -z $SERVICES ]]
  then
  echo -e "\n Sorry, Currently we do not provide that service\n"
  else
  echo -e "$SERVICES" | while read SERVICE_ID BAR NAME
    do 
    echo "$SERVICE_ID) $NAME"
    done
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]] 
  then
  MAIN_MENU "Please enter a valid number"
  else
  AVAIL_SERVICES=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  SERV_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $AVAIL_SERVICES ]]
    then
    MAIN_MENU "No such service exists. Please select a valid service"
    else
    echo -e "\nWhat is your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
     then
     echo -e "\nWhat is your name?"
     read CUSTOMER_NAME
     INSERT_CUSTOMER=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")     
    fi
  echo -e "\nWhat time would you like your $(echo $SERV_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    if [[ $SERVICE_TIME ]]
    then
    INSERT_SERV_APPOINT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    if [[ $INSERT_SERV_APPOINT ]]
    then
    echo -e "\nI have put you down for a $SERV_NAME at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')."
    fi
    fi
  fi
  fi
  fi
}

MAIN_MENU
