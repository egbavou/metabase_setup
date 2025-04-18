#!/bin/bash

PATH="/home/ubuntu/metabase_setup/"
MYSQL_BASH_FILE_NAME="mysql.sh"
METABASE_BASH_FILE_NAME="metabase.sh"

cd $PATH

sudo chmod +x "$PATH_SETUP/$MYSQL_BASH_FILE_NAME"
sudo chmod +x "$PATH_SETUP/$METABASE_BASH_FILE_NAME"
sudo "$PATH_SETUP/$MYSQL_BASH_FILE_NAME"
sudo "$PATH_SETUP/$METABASE_BASH_FILE_NAME"