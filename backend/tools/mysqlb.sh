#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Simple mysql front end to allow batch processing
#           Based on:
#            mysql -user=root -password= < <(cat 0*.ddl)
#
# Author      Date         Version     Comments                      
# ------      ----------   -------     --------
# Fraioli     2016-01-21       1.0     Created
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
runCommand()
{
 CMD=$1
#
# Initialise ...
 stringToSupress="Using a password"
 noErrors=1
#
# Run ..
 eval $CMD 2>&1 | grep -v "$stringToSupress"
 rc=$?

 if [ $rc -ne $noErrors ];then
   echo "#########################################################"
   echo "!!!!!!! CAUTION: SOMETHING MAY NEED CHECKING HERE !!!!!!!"
   echo "#########################################################"
 fi
}
#----------------------------------------------------------


#########################
# Main
#########################
tput clear

# Customisable persistent variables ..
dependentTool="mysql"

#-----------------------------------
# Initialise ..
#-----------------------------------
product=`basename $0 .sh`

# Assign input arguments ..
if [ $# -eq 3 ] || [ $# -eq 4 ];then
  set -f
  userName=$1
  userPass=$2
  fileWildcard=$3
  runType=$4
  set +f
else
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <user name> <user password> <file (wildcard)> [-fast]"
  echo " "
  echo " e.g. "
  echo "     $product.sh root pa$$w0rD 0\*.ddl "
  echo "     $product.sh root pa$$w0rD 0\*.ddl -fast"
  echo "     $product.sh root pa$$w0rD \*.ddl -fast"
  echo "     $product.sh root pa$$w0rD 01\*.ddl "
  echo "     $product.sh root pa$$w0rD 01_createDB.ddl "
  echo " "
  exit 1
fi

#Run ..
CmdPrefix="$dependentTool --user=$userName --password=$userPass < "
if [ -n "$runType" ] && [ "$runType"="-fast" ] ;then
  Cmd=$CmdPrefix"<(cat $fileWildcard)"
  runCommand "$Cmd"
else
  for file in `ls $fileWildcard`; 
  do 
    echo ""
    echo "-------------------------------------------------------------"
    echo "PROCESSING: [$file]"
    echo "-------------------------------------------------------------"
    Cmd=$CmdPrefix$file
    runCommand "$Cmd"
  done
fi

#-----------------------------------
# Happy end ..
#-----------------------------------
echo ""
