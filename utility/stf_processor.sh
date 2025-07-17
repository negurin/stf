#!/bin/bash

##########################################################
# Copyright (c) 2001-2024 Alexey Kuryakin daqgroup@mail.ru
##########################################################

##########################################################
## Script to call before/after DAQ config start/stop.   ##
##########################################################

###########################################################
source $(crwkit which crwlib_base.sh); # Use base library #
source $(crwkit which crwlib_file.sh); # Use file library #
###########################################################

function daq_preprocessor(){
 local daqcfg="$(basename $CRW_DAQ_CONFIG_FILE)";
 echo "PreProcessor for $daqcfg is running on $(hostname) …";
 unix tooltip-notifier text "$(date +%Y.%m.%d-%H:%M:%S): PreProcessor is running on $(hostname) …" preset stdInfo delay 7000;
};

function daq_postprocessor(){
 local daqcfg="$(basename $CRW_DAQ_CONFIG_FILE)";
 echo "PostProcessor for $daqcfg is running on $(hostname) …";
 unix tooltip-notifier text "$(date +%Y.%m.%d-%H:%M:%S): PostProcessor is running on $(hostname) …" preset stdInfo delay 7000;
};

function daq_processor(){
 # target hosts to run script
 local wanted_hosts="demo-daq-pc";
 # uncomment next line to run on all hosts
 wanted_hosts="$wanted_hosts $(hostname)";
 if word_is_in_list "$(hostname)" "$wanted_hosts"; then
  case $1 in
   pre)  daq_preprocessor;  ;;
   post) daq_postprocessor; ;;
   *) ;;
  esac;
 else
  echo "Skip $1processor on host $(hostname).";
 fi;
};

function main(){
 if [ -z "$CRW_DAQ_SYS_HOME_DIR" ]; then
  fatal 1 "$(langstr ru "Сценарий вызывается только из CRW-DAQ." en "Script should be called from CRW-DAQ only.").";
 fi;
 if [ -z "$CRW_DAQ_CONFIG_FILE" ]; then
  fatal 1 "$(langstr ru "Сценарий вызывается только из DAQ." en "Script should be called from DAQ only.").";
 fi;
 case $1 in
  pre)  daq_processor pre;  ;;
  post) daq_processor post; ;;
  *) 1>&2 echo -e "\n usage:\n $scriptname (pre|post)\n"; return 1; ;;
 esac;
};

main "$@";

##############
## END OF FILE
##############
