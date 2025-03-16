#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=salon -t --no-align -c"

# Display the list of services
echo -e "\n~~~~~ WELCOME TO THE SALON ~~~~~\n"

MAIN_MENU() {
  echo -e "\nHere are the available services:\n"

  # Fetch and display services
  SERVICES=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$SERVICES" | while IFS="|" read SERVICE_ID NAME
  do
    echo "$SERVICE_ID) $NAME"
  done

  # Prompt user for service ID
  echo -e "\nPlease enter the service number you'd like:"
  read SERVICE_ID_SELECTED

  # Validate service ID
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_NAME ]]
  then
    # If invalid, display error and show the main menu again
    echo -e "\nThat is not a valid service. Please select again."
    MAIN_MENU
  else
    # Proceed to gather customer details
    GET_CUSTOMER_DETAILS
  fi
}

GET_CUSTOMER_DETAILS() {
  # Ask for phone number
  echo -e "\nPlease enter your phone number:"
  read CUSTOMER_PHONE

  # Check if customer exists
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  if [[ -z $CUSTOMER_NAME ]]
  then
    # If new customer, ask for name
    echo -e "\nIt looks like you are a new customer. What is your name?"
    read CUSTOMER_NAME

    # Insert new customer into the database
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')")
  fi

  # Fetch customer ID
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

  # Proceed to appointment scheduling
  SCHEDULE_APPOINTMENT
}

SCHEDULE_APPOINTMENT() {
  # Ask for the appointment time
  echo -e "\nWhat time would you like your $SERVICE_NAME appointment?"
  read SERVICE_TIME

  # Insert the appointment into the database
  INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

  # Confirm the appointment
  if [[ $INSERT_APPOINTMENT_RESULT == "INSERT 0 1" ]]
  then
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  else
    echo -e "\nSorry, there was an issue scheduling your appointment. Please try again."
    MAIN_MENU
  fi
}

# Start the script
MAIN_MENU
