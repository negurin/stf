#!/bin/bash

###########################################################
## Client configuration generator
###########################################################

###########################################################
source $(crwkit which crwlib_base.sh); # Use base library #
source $(crwkit which crwlib_file.sh); # Use file library #
###########################################################

######################
# Initialize variables
######################
readonly dim_client="${scriptbase}.cfg"; # DIM client configuration
readonly dim_dic="stf_dim_dic.cfg";     # DIM client services
readonly dim_ctrl="stf_dim_ctrl.cfg";   # DIM client control program
readonly dim_tags="stf_dim_tags.cfg";   # DIM client tags and curves

#######################
# Generate DIM services
#######################
function DIMClient(){
 delete_files $dim_client;
 MakeClient >> $dim_client;
 for cfg in $dim_client; do unix2dos $cfg; done;
};

function MakeClient(){
 cat $dim_dic;
 cat $dim_ctrl;
 cat $dim_tags;
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
  DIMClient;
 fi;
 popd >/dev/null 2>&1;
};

main "$@";

##############
## END OF FILE
##############
