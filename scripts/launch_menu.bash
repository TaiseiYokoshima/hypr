#!/bin/bash
launcher=$1
class=$2
cmd="${@:3}"

echo "got"
echo "launcher: $launcher"
echo "cmd: $cmd"

$HOME/.config/hypr/scripts/smart_launch_menu.bash $launcher $class 
eval "$cmd "

