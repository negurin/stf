#!/bin/bash

##########################################################
# Copyright (c) 2001-2024 Alexey Kuryakin daqgroup@mail.ru
##########################################################

##########################################################
# Switch simulation: replace (_hdw|_hdw-),(_sim-|_sim).
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

function main(){
 exec $scriptHOME/hardwareon.sh OFF;
};

main "$@";

##############
## END OF FILE
##############
