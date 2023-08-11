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
   #TODO: make script have optional arg for user trick version

   NumCores="$(grep processor /proc/cpuinfo | wc -l)"
   #echo "$NumCores"
   export MAKEFLAGS="-j $NumCores"
  date
  #TODO: check all of the exit codes
  is_dir ./UserTrick && cd ./UserTrick && export TRICK_HOME="$(pwd)" && cd ../ 
  is_dir ./UserProject  && cd ./UserProject/SIM_Ball++_L1/ && make spotless && $TRICK_HOME/bin/trick-CP && exit 0
  mkdir UserProject
  echo "Git Trick"
  git clone https://github.com/nasa/trick UserTrick >& /dev/null
  cd ./UserTrick
  #git checkout tags/19.6.0 -b 19.6.0
  git checkout tags/19.3.1 -b 19.3.1
  echo "Configure Trick"
  ./configure >& ./config.out.out
  echo "Build Trick"
  make -j $NumCores >& ./build.out.out
  export TRICK_HOME="$(pwd)"
  echo $TRICK_HOME
  cp -r ./trick_sims/SIM_Ball++_L1/ ../UserProject/
  cd ..

  echo "RUN_test/input.py" > ./test.rc.cfg
  echo "RUN_Rick_Other/input.py" >> ./test.rc.cfg
  
  cd ./UserProject/
  cd ./SIM_Ball++_L1/

  echo "Build Sim"
  $TRICK_HOME/bin/trick-CP >& ./sim.build.out.out
  cp -r ./RUN_test/ ./RUN_Rick_Other
  
  echo "Seding"
  sed -i 's/drg0 = trick.DRAscii("Ball")/drg0 = trick.DRBinary("Ball")/g' ./RUN_Rick_Other/input.py

  sed -i 's/trick.stop(300.0)/trick.stop(42.0)/g' ./RUN_Rick_Other/input.py

  sed -i 's/#trick.checkpoint_post_init(True)/trick.checkpoint_post_init(True)/g' ./RUN_Rick_Other/input.py

  sed -i 's/#trick.checkpoint_end(True)/trick.checkpoint_end(True)/g' ./RUN_Rick_Other/input.py

  #sed -i 's/old-text/new-text/g' ./RUN_Rick_Other/input.py


  echo "Run Sim Run 01"
  find ./ -maxdepth 1 -type f -iname "S_main*.exe" -exec {} ./RUN_test/input.py \; >& ./RUN_test/run.out.out
  echo "Run Sim Run 02"
  find ./ -maxdepth 1 -type f -iname "S_main*.exe" -exec {}  ./RUN_Rick_Other/input.py \; >& ./RUN_Rick_Other/run.out.out


  echo "Done"
  date
  #TODO: Generate config file


fi
