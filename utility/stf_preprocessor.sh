#!/bin/bash

##########################################################
# Copyright (c) 2001-2024 Alexey Kuryakin daqgroup@mail.ru
##########################################################

##########################################################
## Script to call before DAQ configuration started.     ##
##########################################################

###########################################################
source $(crwkit which crwlib_base.sh); # Use base library #
source $(crwkit which crwlib_file.sh); # Use file library #
###########################################################

function main(){
 $scriptHOME/${scriptname/preprocessor/processor} pre "$@";
};

main "$@";

##############
## END OF FILE
##############
