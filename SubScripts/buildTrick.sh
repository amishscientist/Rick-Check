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

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
   trap cleanup EXIT
   # Script goes here
   # ...
   #find ./ -maxdepth 6 -type d -name atlas -print0 | xargs -0 -n 1 -P 5 sub_stub 
   #date +'%Y-%m-%d_%H_%M_%S'
   #TODO: I should pass in number of cores to uses.

   date
   cd ./$1
   make  >& ./$1.build.out.out

   buildExitCode=$?
   echo $buildExitCode > ./$1.build.exitCode.out.out


fi
