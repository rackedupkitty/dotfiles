#!/bin/bash

# Get the current day of the month
day=$(date +10#%d)

# Define the path to the config file
config_file="/home/kitty/.config/swaylock/config"

# Check if the day is a single digit
if [[ $day -lt 10 ]]; then
  # If single digit, remove space between %B and %e
  sed -i 's/datestr=%a, %B %e/datestr=%a, %B%e/' "$config_file"
else
  # If two digits, add space between %B and %e
  sed -i 's/datestr=%a, %B%e/datestr=%a, %B %e/' "$config_file"
fi
