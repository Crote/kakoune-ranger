# Open files previously chosen by ranger, stored in param 1
def -hidden ranger-execute-open -params 1 %{ evaluate-commands %sh{
  while [ ! -f $1 ]; do
    sleep 0.1
  done
  while read f; do
    echo "edit '$f';"
  done < $1
}}

# Change server directory to one previously chosen by ranger
def -hidden ranger-execute-cd -params 1 %{ evaluate-commands %sh{
  while [ ! -f $1 ]; do
    sleep 0.1
  done
  echo "change-directory $(cat $1)"
}}

# Helper to allow another program to take over the terminal
def -hidden ranger-suspend -params 1 %{ evaluate-commands %sh{
  parent_pid=$(cat /proc/$kak_client_pid/status | grep PPid | sed 's/[^0-9]*\([0-9]\+\)$/\1/g')
  parent_bin=$(realpath /proc/$parent_pid/exe)
  shell_blacklist="\(/tmux\|/screen\)"
  valid_shell=$(cat /etc/shells | grep -v "$shell_blacklist" | grep $parent_bin | wc -l)
  if [ $valid_shell == 0 ]; then
    echo "fail \"Cannot open ranger: client not running in a shell!\""
    exit
  fi
  nohup sh -c "sleep 0.1; xdotool type --delay 2 \"$1\"; xdotool key Return" > /dev/null 2>&1 &
  /usr/bin/kill -SIGTSTP $kak_client_pid
  echo "nop"
}}

# Run ranger to select files, using the specified file to pass the selection
def -hidden ranger-select-internal -params 1 %{
  nop %sh{rm "$1" }
  ranger-suspend "ranger --choosefiles='%arg{1}' && touch '%arg{1}' && history -d \$(history 1); clear; fg"
  ranger-execute-open %arg{1}
}

# Run ranger to select directory
def -hidden ranger-cd-internal -params 1 %{
  nop %sh{rm "$1" }
  ranger-suspend "ranger --show-only-dirs --choosedir='%arg{1}' && touch '%arg{1}' && history -d \$(history 1); clear; fg"
  ranger-execute-cd %arg{1}
}

# User-facing commands

# We're creating a new tmp file on every execution, but that'll be cleaned up on reboot so we don't care
def -docstring "Select files to edit using ranger" ranger-select %{
  ranger-select-internal %sh{ mktemp }
}

def -docstring "Navigate to directory to cd into using ranger" ranger-cd %{
  ranger-cd-internal %sh{ mktemp }
}
