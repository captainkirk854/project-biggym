#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Convenience tool to quickly run unit tests for sprocs
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-02-06       1.0     Created
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
fnRunMyTapUnitTest()
#----------------------------------------------------------
{
 dir=$1
 suffix=$2

 if [ -d $dir ];then
   echo ""
   echo "============================================================================================================="
   echo "USING [$suffix] FILE(S) IN [$dir] .."
   cd $dir > /dev/null 2>&1
   mysqlb.sh $userName $userPass \*.$suffix -suppress
   cd - > /dev/null 2>&1
 else
   echo "[$dir] not found!"
 fi
}
#----------------------------------------------------------




#########################
# Main
#########################
tput clear

# Customisable persistent variables ..
cfgProjectRoot="$HOME/code/github/captainkirk854/project-BigGym/backend/BIGGYM"
cfgTEST="$cfgProjectRoot/tests"
cfgAPI="$cfgTEST/api"
cfgUnitTestSuffix=ut


#-----------------------------------
# Initialise ..
#-----------------------------------
product=`basename $0 .sh`

# Assign input arguments ..
if [ $# -eq 2 ];then
  userName=$1
  userPass=$2
else
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <user name> <user password> "
  echo " "
  echo " e.g. "
  echo "     $product.sh root pa$$w0rD  "
  echo " "
  exit 1
fi

currDir=`pwd`

#Run ..
#--------------------------
# Functions and Stored Procedures ..
#--------------------------
echo "Testing: Functions and Stored Procedures .."
fnRunMyTapUnitTest $cfgAPI/create $cfgUnitTestSuffix
fnRunMyTapUnitTest $cfgAPI/delete $cfgUnitTestSuffix
fnRunMyTapUnitTest $cfgAPI/get $cfgUnitTestSuffix
fnRunMyTapUnitTest $cfgAPI/update $cfgUnitTestSuffix
fnRunMyTapUnitTest $cfgAPI/util $cfgUnitTestSuffix

#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
