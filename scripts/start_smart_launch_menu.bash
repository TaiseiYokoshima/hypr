#!/bin/bash
launcher=$1
class=$2

echo "now running"
echo "$$" > $HOME/.config/hypr/scripts/smart_launch_menu_pid.txt

socat_pid=""
fifo_path="/tmp/taiseis_hypr_socket_fifo"

cleanup() {
  echo "terminating, about to kill socat: $socat_pid"
  if [[ -n "$socat_pid" ]] && kill -0 "$socat_pid" 2>/dev/null; then
    kill "$socat_pid"
  else
    echo "no socat pid"
  fi

  [[ -p "$fifo_path" ]] && rm -f "$fifo_path"
  pkill -x $launcher
  echo "" > $HOME/.config/hypr/scripts/smart_launch_menu_pid.txt
  echo "terminated"
}

trap cleanup EXIT 


window_id=""

handle() {
  echo $1

  if [[ "$window_id" != "" ]]; then 
    [[ "$1" == *"activewindowv2>>"* && "$1" != *"activewindowv2>>$window_id"* ]] && echo "changed window focus" && exit
    [[ "$1" == *"closewindow>>"* && "$1" == *"closewindow>>$window_id"* ]] && echo "window closed" && exit
  fi
  
  if [[ "$1" == *"openwindow>>"* && "$1" == *",$class"*  ]]; then
    string="${1/"openwindow>>"/}"
    string="${string/",$class"/}"
    string=$(echo "$string" | sed 's/,.*//')
    window_id=$string
    echo "Match found: [$window_id]"
  fi


  [[ "$1" == *"focusedmon>>"* ]] && echo "changed output focus" && exit
}

if [[ ! -p "$fifo_path" ]]; then
  mkfifo "$fifo_path"
fi

socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock > "$fifo_path"  2> /dev/null &
socat_pid=$!


while read -r line; do
  handle "$line" 
done < "$fifo_path"

