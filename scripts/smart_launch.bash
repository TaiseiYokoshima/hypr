#!/bin/bash
launcher=$1
class=$2


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
}

trap cleanup EXIT 



exit_flag=false
handle() {
  echo $1
  if [[ "$exit_flag" == "true" ]]; then 
    ! pgrep -x "$launcher" > /dev/null && exit || echo "$launcher is running"
   [[ "$1" == *"activewindow>>"* && "$1" != *"activewindow>>$class,"* ]] && exit
  fi
  

  [[ "$1" == *"activewindow>>$class,"* ]] && echo "hit true" && exit_flag="true"
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

