# Open files previously chosen by ranger, stored in /tmp/ranger-files
def -hidden ranger-execute-open -params 1 %{ evaluate-commands %sh{
  while read f; do
    echo "edit '$f';"
  done < $1
}}

# Helper to allow another program to take over the terminal
def -hidden ranger-suspend -params 1 %{ evaluate-commands %sh{
  parent_pid=$(cat /proc/$kak_client_pid/status | grep PPid | sed 's/[^0-9]*\([0-9]\+\)$/\1/g')
  parent_bin=$(realpath /proc/$parent_pid/exe)
  shell_blacklist="\(/tmux\|/screen\)"
  valid_shell=$(cat /etc/shells | grep -v "$shell_blacklist" | grep $parent_bin | wc -l)
  echo "echo -debug \"my pid: $kak_client_pid, parent: $parent_pid, parent exec: $parent_bin valid: $valid_shell\""
  if [ $valid_shell == 0 ]; then
    echo "fail \"Cannot open ranger: client not running in a shell!\""
    exit
  fi
  nohup sh -c "sleep 0.1; xdotool type --delay 2 '$1'; xdotool key Return" > /dev/null 2>&1 &
  /usr/bin/kill -SIGTSTP $kak_client_pid
  echo "nop"
}}

# Run ranger to select files, using the specified file to pass the selection
def -hidden ranger-select-internal -params 1 %{
  ranger-suspend "ranger --choosefiles='%arg{1}' &&fg;history -d $(history 1);clear"
  ranger-execute-open %arg{1}
}

# User-facing command
# We're creating a new tmp file on every execution, but that'll be cleaned up on reboot so we don't care
def -docstring "Select files to edit using ranger" ranger-select %{
  ranger-select-internal %sh{ mktemp }
}
