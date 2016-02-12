#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Constant runner wrapper for Unit Tester ..
#
# Dependencies: > runMYTAPUnitTests.sh
#               > morepause 
#---------------------------------------------------------------------------------------------------------------------

#########################
# Main
#########################
tput clear

#-----------------------------------
# Initialise ..
#-----------------------------------
product=`basename $0 .sh`

# Assign input arguments ..
if ([ $# -eq 2 ] || [ $# -eq 3 ]);then
  userName=$1
  userPass=$2
  pauseTime=$3
else
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <user name> <user password> "
  echo " "
  echo " e.g. "
  echo "     $product.sh root pa$$w0rD"
  echo "     $product.sh root pa$$w0rD 5"
  echo " "
  exit 1
fi


# Run ..
while [ 1 ]; 
do 
  runMYTAPUnitTests.sh $userName $userPass | morepause $pauseTime
done
