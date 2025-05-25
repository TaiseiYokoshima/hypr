#!/bin/bash
launcher=$1
class=$2

pkill -x "$launcher"
$HOME/.config/hypr/scripts/kill_smart_launch_menu.bash

echo "pid: $(cat $HOME/.config/hypr/scripts/smart_launch_menu_pid.txt)"
$HOME/.config/hypr/scripts/start_smart_launch_menu.bash $launcher $class &
