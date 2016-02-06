#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Simple mysql front end to allow batch processing
#           Based on:
#            mysql -user=root -password= < <(cat 0*.ddl)
#
# Author      Date         Version     Comments                      
# ------      ----------   -------     --------
# Fraioli     2016-01-21       1.0     Created
# Fraioli     2016-02-06       1.1     Updated with -suppress option (specifically to run with mytap unit tests)
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
 stringToSuppress="Using a password"
 noErrors=1
#
# Run ..
 eval $CMD 2>&1 | grep -v "$stringToSuppress"
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
#tput clear

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
CmdRoot="$dependentTool --user=$userName --password=$userPass "
CmdPrefix="$CmdRoot < "

if [ "$runType" == "-fast" ];then
  Cmd=$CmdPrefix"<(cat $fileWildcard)"
  runCommand "$Cmd"
elif [ "$runType" == "-suppress" ];then
  OutputSuppressionOptions="--disable-pager --batch --raw --skip-column-names --unbuffered --execute "
  Cmd="$CmdRoot $OutputSuppressionOptions"
  for file in `ls $fileWildcard`; 
  do 
    echo ""
    echo "-------------------------------------------------------------"
    echo "PROCESSING: [$file]"
    echo "-------------------------------------------------------------"
    CmdWithArgs="$Cmd 'source $file'"
    runCommand "$CmdWithArgs"
  done
elif [ ! -n "$runType" ];then
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
