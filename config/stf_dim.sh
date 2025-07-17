#!/bin/bash

###########################################################
## Configuration generator for DIM services
###########################################################

###########################################################
source $(crwkit which crwlib_base.sh); # Use base library #
source $(crwkit which crwlib_file.sh); # Use file library #
###########################################################

######################
# Initialize variables
######################
readonly diccfg="${scriptbase}_dic.cfg";                # DIM client configuration
readonly discfg="${scriptbase}_dis.cfg";                # DIM server configuration
readonly devmsg="devPostMsg";                           # Method to send/post messages
declare FN="STF";                                      # Facility name
declare SS="DIM";                                       # Subsystem name
declare FP="$(echo -n "$FN" | tr '.' '/')";             # Facility DIM  path, i.e. FN name with . to / replacement
declare FF="$(echo -n "$FN" | tr '.' '_')";             # Facility file name, i.e. FN name with . to _ replacement
declare FF="$(echo -n "$FF" | tr [:upper:] [:lower:])"; # Facility file name in lower case

#######################
# Generate DIM services
#######################
function dim_services(){
 delete_files $diccfg $discfg;
 DIM_DIS  >> $discfg;
 DIM_DIC  >> $diccfg;
 DIC_CTRL >> $diccfg;
 for cfg in $diccfg $discfg; do unix2dos $cfg; done;
};

function DIM_DIS(){
 unix dimcfg \
  -n section  "[&$FN.$SS.CTRL]" \
  -n print    DimServerMode = 1 \
  -n end \
  -n dis_cmnd $FP/$SS/DIMGUICLICK \
  -n tag      $FN.$SS.DIMGUICLICK \
  -n $devmsg "&$FN.$SS.CTRL @DIMGUICLICK=%%**" \
  -n end \
  -n dic_cmnd $FP/$SS/DIMGUICLICK \
  -n tag      $FN.$SS.DIMGUICLICK \
  -n end \
  -n dis_info $FP/$SS/CLOCK \
  -n tag      $FN.$SS.CLOCK \
  -n end \
  -n dis_info $FP/$SS/SERVID \
  -n tag      $FN.$SS.SERVID \
  -n end \
  -n ;
  echo;
};

function DIM_DIC(){
 unix dimcfg \
  -n section  "[&$FN.$SS.CTRL]" \
  -n print    DimClientMode = 1 \
  -n end \
  -n dic_cmnd $FP/$SS/DIMGUICLICK \
  -n tag      $FN.$SS.DIMGUICLICK \
  -n end \
  -n dic_info $FP/$SS/CLOCK \
  -n tag      $FN.$SS.CLOCK \
  -n $devmsg "&$FN.$SS.CTRL @DimTagUpdate=$FN.$SS.CLOCK" \
  -n end \
  -n dic_info $FP/$SS/SERVID \
  -n tag      $FN.$SS.SERVID \
  -n $devmsg "&$FN.$SS.CTRL @DimTagUpdate=$FN.$SS.SERVID" \
  -n end \
  -n ;
  echo;
};

function DIC_CTRL(){
 echo "[DataStorage]";
 echo "[]";
 echo;
 echo "[TagList]";
 echo "[]";
 echo;
 echo "[&$FN.$SS.CTRL]";
 echo "[]";
 echo;
};


##############
# Delete files
##############
function delete_files(){
 while [ -n "$1" ]; do
  if [ -e "$1" ]; then rm -f "$1"; fi;
  shift;
 done;
};

###############
# Main function
###############
function main(){
 if pushd $scriptHOME >/dev/null 2>&1; then
  dim_services;
 fi;
 popd >/dev/null 2>&1;
 local code=$?;
 if [ $code -eq 0 ]; then
  local msg="$(langstr ru "Конфигурация успешно создана" en "Configuration created")";
  unix tooltip-notifier preset stdOk delay 7000 text "$scriptname: $msg";
 else
  local msg="$(langstr ru "Ошибка создания конфигурации" en "Failed on create configuration")";
  fatal $code "$scriptname: $msg";
 fi;
 return $code;
};

main "$@";

##############
## END OF FILE
##############
