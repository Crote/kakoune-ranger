# Open files previously chosen by ranger, stored in /tmp/ranger-files
def -hidden ranger-execute-open -params 1 %{ evaluate-commands %sh{
  while read f; do
    echo "edit '$f';"
  done < $1
}}

# Helper to allow another program to take over the terminal
def -hidden ranger-suspend -params 1 %{ nop %sh{
  nohup sh -c "sleep 0.1; xdotool type --delay 2 '$1'; xdotool key Return" > /dev/null 2>&1 &
  /usr/bin/kill -SIGTSTP $PPID
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
