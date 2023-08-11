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
is_NOT_file() { local file=$1 ; [[ ! -f $file ]] ; }
is_dir() { local dir=$1 ; [[ -d $dir ]] ; }
is_NOT_dir() { local dir=$1 ; [[ ! -d $dir ]] ; }

cleanup() {
    # Remove temporary files
    # Restart services
    # ...
    true # you can't have an empty funciton.
}

if [[ "${BASH_SOURCE[0]}" = "$0" ]]; then
   trap cleanup EXIT
   #TODO: Run shell check.
   #TODO: Set up CI
   NumCores="$(grep processor /proc/cpuinfo | wc -l)"
   export MAKEFLAGS="-j $NumCores"
   
   ### Arg Check ###
   if [ $# -ne 3 ]; 
   then
       echo "This isn't good. You don't have enough args." 
       exit 1
   fi

   #TODO:I Probably need to do more checking to see if the trick is built.
   is_NOT_file $1/bin/trick-gte && echo "Arg one doens't ponit to anything trick like" && exit 1; 
   echo "Looks like we have found something trick like."
   #TODO:Check find what arguments they built the user version with so this script can use them.
   is_NOT_dir $2 && echo "Arg two isn't a real directory." && exit 1;
   #TODO I should do a S_main*.exe check
   is_NOT_file $3 && echo "Arg three isn't a real file." && exit 1;
   #TODO: Need to write a seprate script to validate sim config file. Check to make sure there is atleast one sim and one run/input file. Check to see if all the files in there actually exist.


   #TODO: I probably put trk/csv you want skipt in the config file.

   UserTrick=$1
   UserSimDir=$2
   UserSimConfigFile=$3
   
   ### Pull down trick
   mkdir Narnia
   cd Narnia
   $UserTrick/bin/trick-version > temp.out.out
   UserTrickVersion="$(cut -d " " -f 3 ./temp.out.out)"
   git clone https://github.com/nasa/trick Head
   cd Head
   git tag --list > ../listOfTags.out.out
   cd ..
   awk -v var=$UserTrickVersion 'BEGIN{start=0;}{if(start==1){print $0;}if($0==var){print $0;start=1;}}' ./listOfTags.out.out > listOfTricks.out.out  
   echo "Get Other Tricks"
   tac ./listOfTricks.out.out | xargs -n 1 -P $NumCores ../SubScripts/getTrick.sh >& /dev/null
   echo "Head" >> ./listOfTricks.out.out
   echo "Configure Tricks"
   tac ./listOfTricks.out.out | xargs -n 1 -P $NumCores ../SubScripts/confTrick.sh
   #TODO: I should make sure they configure and make the list smaller if needed.
   echo "Build Tricks"
   tac ./listOfTricks.out.out | xargs -n 1 -P 1 -t  ../SubScripts/buildTrick.sh
   find ./ -maxdepth 3 -type f -name "libtrick.a" | sort -h >& listOfTricksThatBuilt.out.out
   find `pwd -P` -maxdepth 3 -type f -name "trick-CP" | sort -h | nl >& listOfTrick.out.out
   cd ..

   #TODO: Check for already built trick versions.

   ### Self Check ###
   # Checksum exe and store it off.
   UserSimName="$(find $UserSimDir -maxdepth 1 -type f -iname "S_main*.exe")"
   UserSimCheckSum="$(md5sum $UserSimName | cut -d " " -f 1)"
   #echo "CHECKSUM::$UserSimCheckSum" 
   cp $UserSimName ./Narnia/
   mkdir $UserSimDir/The_Rick_Pit_And_Resort
   cp ./SubScripts/buildAndRun.sh $UserSimDir
   cp ./Narnia/listOfTrick.out.out $UserSimDir

   cd $UserSimDir
   #TODO: Need to improve self check.
   tac  ./listOfTrick.out.out | xargs -n 2 -P 1 -t ./buildAndRun.sh


   #cmp -l ./S_main_.exe ../S_main_.exe | gawk '{printf "%08X %02X %02X\n", $1-1, strtonum(0$2), strtonum(0$3)}' > cmp.out.out
   # TODO: Check exit code, reason for termination 
   # and simtime. TODO: Diff trk/cvs files. TODO: If 
   # Pre/Post init check points are there compair 
   # them. If Self Test fails tell user and quit. If 
   # Self Test Passes. Get latest trick version and 
   # all taged verisons of trick.
   ## It would be nice to run coverage and asan on 
   ## latest and most recent taged version.
   # Remove users trick version if it is in the 
   # list. Clone all versions of trick.
   ### LLVM build check.
   # Configure all versions of trick. Revome all 
   # verions of trick that don't configure form the 
   # list. Build all verions in the list. Remove 
   # versions of trick that don't build from the 
   # list. Rebuild sim. Do trick check to make sure 
   # it is pointed at the new trick. Run all runs 
   # Don't forget to store exit codes.
   #Then compair all run data to user trick version.

fi
