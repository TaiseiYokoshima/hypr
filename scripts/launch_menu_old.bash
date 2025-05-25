#!/bin/bash
launcher=$1
class=$2
cmd="${@:3}"


echo "got"
echo "launcher: $launcher"
echo "cmd: $cmd"



exit_flag=false


if pgrep -x "$launcher" > /dev/null; then 
  pkill -x "$launcher"
fi

# wofi --show drun -n &
eval "$cmd &"


handle() {
  if pgrep -x "$launcher" > /dev/null; then
    echo "$launcher is running"
  else 
    exit
  fi


  echo $1

  if [[ "$1" == *"activewindow>>$class,"* ]]; then 
    echo "hit true"
    exit_flag="true"
    continue
  fi

  if [[ "$1" == *"focusedmon>>"* ]]; then
    echo "terminating"
    pkill -x $launcher 
    exit
  fi 


  if [[ "$exit_flag" == "true" && "$1" == *"activewindow>>"* && "$1" != *"activewindow>>$class,"* ]]; then
      echo "terminating"
      pkill -x $launcher
      exit
  fi
}


socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
