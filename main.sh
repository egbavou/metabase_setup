#!/bin/bash

if [ "$EUID" -ne 0 ]; then 
  echo "You need to run this script as root."
  exit 1
fi

PATH="/tmp/metabase_setup/"
MYSQL_BASH_FILE_NAME="mysql.sh"
METABASE_BASH_FILE_NAME="metabase.sh"

cd "$SETUP_PATH" || { echo "The folder $SETUP_PATH doesn't exist."; exit 1; }

sudo -i

chmod +x "$PATH_SETUP/$MYSQL_BASH_FILE_NAME"
chmod +x "$PATH_SETUP/$METABASE_BASH_FILE_NAME"
"$PATH_SETUP/$MYSQL_BASH_FILE_NAME"
"$PATH_SETUP/$METABASE_BASH_FILE_NAME"