#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

#-|
#/ Usage:
#/ Description:
#/ Examples:
#/ Options:
#/   --help: Display this help message
usage() { grep '^#/' "$0" | cut -c4- ; exit 0 ; }
expr "$*" : ".*--help" > /dev/null && usage

#-|
readonly LOG_FILE="/tmp/$(basename "$0").log"
sLog()     { echo "[LOG]     $*" >> "$LOG_FILE";            }
sInfo()    { echo "[INFO]    $*" | tee -a "$LOG_FILE" >&2 ; }
sWarning() { echo "[WARNING] $*" | tee -a "$LOG_FILE" >&2 ; }
sError()   { echo "[ERROR]   $*" | tee -a "$LOG_FILE" >&2 ; }
sFatal()   { echo "[FATAL]   $*" | tee -a "$LOG_FILE" >&2 ; exit 1 ; }

is_empty() { local var=$1 ; [[ -z $var ]] ; }
is_not_empty() { local var=$1 ; [[ -n $var ]] ; }
is_file() { local file=$1 ; [[ -f $file ]] ; }
is_dir() { local dir=$1 ; [[ -d $dir ]] ; }

cleanup() {
    # Remove temporary files
    # Restart services
    # ...
    true # you can't have an empty funciton.
}


#-|
# Bash NOTES:
# To get around e for strict mode
#    set +e
#    command_returning_non_zero     OR  command_returning_non_zero || true
#    set -e
#
# Turn on debug bash -x ./stub.sh or put set -x and set +x around the section
#    you want to debug.  It should print all commands to the screen.
#
# "CommandOne && CommandTwo" Only run CommandTwo if CommandOne is succesful. 
# 
# xargs  I sometime "command || true" if I'm ssh. If a single xargs command fails 
#    it stops all of them.
#
# Don't forget to ./ in front of file names.
#
# Example is_dir: is_dir "/tmp" && echo "There is a /tmp dir"
#
# Var don't forget you can make them "local" and "readonly"
#    Naming arguments helps "my_arg=${1:-"default"}" 
#    Don't forget to quote all var. "$var" to prevent globbing 
#    and word splitting.
#    
# Var defaults. 
#   name=${fname:?"fname not defined"} #Exits with a status of 1 
#                         # And displays "fname not defined"
#   name=${fname:-Jason}  #Returns Jason if fname is undefind or null
#                          # But doesn't change the value of fname.
#   name=${fname:=Jason}  #Returns Jason if fname is undefind or null
#                          # And changes the value of fname to Jason.
#   name=${fname:+Jason}  #Returns Jason if fname is defind and not null
#                          # But doesn't hanges the value of fname.
#
# How to store command output in a var. 
#
#   OUTPUT="$(echo -e 'one\ttwo')"
#   echo "${OUTPUT}"
#   OUTPUT=( $(echo -e 'one\ttwo') )
#   echo "${OUTPUT[@]}"
#   echo "${OUTPUT[1]}"
#
# Screen output for above
#one	two
#one two
#two
#
# Bash Arrays
#   declare -a array=("California" "New York" "Nevada" "Utah")
#   echo "Number of elements in the array: "${#array[@]} 
#   echo "\${array[0]} = ${array[0]}"
#
# Screen output for above
#Number of elements in the array: 4
#$array[0] = California
#
# Bash Associative Arrays
#   declare -A aArray=( ["CA"]="California" ["NY"]="New York" \
#                       ["NV"]="Nevada" ["UT"]="Utah")
#   echo "\${aArray["CA"]} = ${aArray["CA"]}"
#
# Screen output for above
#${aArray[CA]} = California
#
# I/O Redirection.
#  1>filename # Redirect stdout to file "filename."
#  2>filename # Redirect stderr to file "filename."
#  &>filename # Redirect both stdout and stderr to file "filename."
#  2>&1 # Redirects stderr to stdout.
#  >> filename # append to file “filename”
#
# BASH Variables
# $# -- Number of command-line args
# $0 -- Script name
# $1 -- First arg $2 Second arg and so on. $@ -- String with each arg quoted.
# $PPID -- Parent PID
# $$ -- Your PID.
# $! -- PID of child pid. 
# $? -- exit code of last command.
# $PWD -- PWD when script was run.
# $FUNCNAME -- function name. $LINENO -- Line number. $HOSTNAME -- host name
# $USER -- user name
# $SECONDS -- how long the script has been running.
# $RANDOM -- A randome number. 
#
# Why use a bash builtin. For performance. Every none builtin requires a fork.
# Some bash builtins may not have the same switches as the linux command 
# version. The Bash builtin for time has no -v option for example. 
#
# "help" is the best way to find out what your bash builtins are. Or you can
# Use the "type" command. 
#
# [Desktop]$ type echo
# echo is a shell builtin
# 
# DON'T FORGET to run shellcheck 
# In tricklab /users/jborland/shellcheck_sl6 -x -a scriptName.sh

#-|
if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
   trap cleanup EXIT
   # Script goes here
   # ...
   #find ./ -maxdepth 6 -type d -name atlas -print0 | xargs -0 -n 1 -P 5 sub_stub 
   #date +'%Y-%m-%d_%H_%M_%S'

   make apocalypse >& /dev/null
   $2 >& ./The_Rick_Pit_And_Resort/build.$1.out.out
   buildExitCode=$?
   echo $buildExitCode > ./The_Rick_Pit_And_Resort/buildExitCode.$1.out.out

   simName="$(find ./  -maxdepth 1 -type f -iname "S_main*.exe")"
   cp $simName ./The_Rick_Pit_And_Resort/S_main_$1.exe
   mkdir ./The_Rick_Pit_And_Resort/RUN_Rick_01_$1

   #-d Check
   $simName ./RUN_test/input.py -d >& ./The_Rick_Pit_And_Resort/RUN_Rick_01_$1/DashD.out.out
   dashDExitCode=$?
   echo $dashDExitCode > ./The_Rick_Pit_And_Resort/RUN_Rick_01_$1/dashDExitCode.out.out

   #Run
   $simName ./RUN_test/input.py -OO ./The_Rick_Pit_And_Resort/RUN_Rick_01_$1 >& ./The_Rick_Pit_And_Resort/output.$1.out.out
   exitCode=$? 
   echo $exitCode > ./The_Rick_Pit_And_Resort/RUN_Rick_01_$1/exitCode.out.out


   mkdir ./The_Rick_Pit_And_Resort/RUN_Rick_02_$1

   #-d Check
   $simName ./RUN_Rick_Other/input.py -d >& ./The_Rick_Pit_And_Resort/RUN_Rick_02_$1/DashD.out.out
   mydashDExitCode=$?
   echo $mydashDExitCode > ./The_Rick_Pit_And_Resort/RUN_Rick_02_$1/dashDExitCode.out.out

   #Run
   $simName ./RUN_Rick_Other/input.py -OO ./The_Rick_Pit_And_Resort/RUN_Rick_02_$1 >& ./The_Rick_Pit_And_Resort/output.$1.out.out
   myexitCode=$? 
   echo $myexitCode > ./The_Rick_Pit_And_Resort/RUN_Rick_02_$1/exitCode.out.out


fi
