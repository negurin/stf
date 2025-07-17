#!/bin/bash

##########################################################
# Copyright (c) 2001-2024 Alexey Kuryakin daqgroup@mail.ru
##########################################################

##########################################################
# Switch hardware mode: replace (_hdw-|_hdw),(_sim|_sim-).
##########################################################

# script identification.
########################
readonly startupdir="$(pwd -LP)";
readonly scriptfile="${BASH_SOURCE[0]}";
readonly scriptname="$(basename $scriptfile)";
readonly scriptbase="$(basename $scriptfile .sh)";
readonly scripthome="$(dirname  $scriptfile)";
readonly scriptFILE="$(realpath $scriptfile)";
readonly scriptHOME="$(dirname  $scriptFILE)";

# set ConfigFileList:
#####################
declare cfg="";
cfg="$cfg config/stf_daq.cfg";

#######################################################################
# Replace _hdw.cfg  to _hdw-.cfg, _sim-.cfg to _sim.cfg  for simulation
# Replace _hdw-.cfg to _hdw.cfg,  _sim.cfg  to _sim-.cfg for hardware
#######################################################################
function replace_hdw_sim(){
 for i in $1; do
  if [ -e "$i" ]; then
   case $2 in
    OFF|Off|off) sed -e 's/_hdw\.cfg/_hdw\-\.cfg/ig' -e 's/_sim\-\.cfg/_sim\.cfg/ig' -i $i; ;;
    *)           sed -e 's/_hdw\-\.cfg/_hdw\.cfg/ig' -e 's/_sim\.cfg/_sim\-\.cfg/ig' -i $i; ;;
   esac;
  fi;
 done;
};

function main(){
 if pushd $scriptHOME >/dev/null 2>&1; then
  replace_hdw_sim "$cfg" $1;
 fi;
 popd >/dev/null 2>&1;
};

main "$@";

##############
## END OF FILE
##############
