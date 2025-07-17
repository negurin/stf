#!/bin/bash

###########################################################
## Copyright (c) 2002-2024 Alexey Kuryakin daqgroup@mail.ru
###########################################################

###########################################################
## clear temporary (garbage) files in script directory.
###########################################################

###########################################################
source $(crwkit which crwlib_base.sh); # Use base library #
source $(crwkit which crwlib_file.sh); # Use file library #
###########################################################

##################################
# List of garbage files to delete.
##################################
readonly garbage="*.log *.lst *.bak *.con *.tpp *.dcu *.map *.~pas *.~dpr *.~dcu *.\$\$\$ *._cr __backup.daq";

############################################
# delete files from $* in current directory.
############################################
function delete_files(){
 while [ -n "$1" ]; do
  find $PWD/ -type f -name "$1" | xargs -r -n 1 rm -fv;
  shift;
 done;
};

function main(){
 if pushd $scriptHOME >/dev/null 2>&1; then delete_files $garbage; fi;
 popd >/dev/null 2>&1;
};

main "$@";

##############
## END OF FILE
##############
