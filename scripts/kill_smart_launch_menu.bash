#!/bin/bash

script_id=$(cat $HOME/.config/hypr/scripts/smart_launch_menu_pid.txt)
path_str="$HOME/.config/hypr/scripts/start_smart_launch_menu.bash"


echo ""
echo ""

if [[ "$script_id" != "" && "$(ps -p $script_id -o cmd)" == *"$path_str"* ]]; then 

  echo "about to kill start_smart_launch_menu"
  kill -15 "$script_id"
  # wait $script_id
  echo "killed start_smart_launch_menu"

else 
  echo "did not kill"
fi

echo ""
echo ""
