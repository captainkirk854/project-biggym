#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Convenience tool to run multiple unit tests for MYSQL programmatic entities
#
# Dependencies: 
#               > commonFun
#               > mysqlb.sh
#               > morepause
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-02-06       1.0     Created
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
fnRunMyTapUnitTests()
#----------------------------------------------------------
{
 dir=$1
 suffix=$2
#
# Process test and colourise the resultant output accordingly ..
 if [ -d $dir ];then
   echo ""
   echo $sep
   echo "USING [$suffix] FILE(S) IN [$dir] .."
   echo $sep
   cd $dir > /dev/null 2>&1
   # Run test and colour the output stream with different colour formats according to string ..
   mysqlb.sh $userName $userPass \*.$suffix -suppress \
                                                      | GREP_COLOR=$colourTestFail    egrep --colour=always "$grepTestFail" \
                                                      | GREP_COLOR=$colourTestPass    egrep --colour=always "$grepTestPass" \
                                                      | GREP_COLOR=$colourTestWarning egrep --colour=always "$grepTestWarning" \
                                                      | GREP_COLOR=$colourCoreErrors  egrep --colour=always "$grepCoreErrors" \
                                                      | GREP_COLOR=$colourOtherThings egrep --colour=always "$grepOtherThings" 
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
cfgTEST="$cfgProjectRoot"
cfgAPI="$cfgTEST/api"
cfgUnitTestSuffix=ut

#-----------------------------------
# Assign input arguments ..
#-----------------------------------
product=`basename $0 .sh`
if ([ $# -ge 2 ]);then
  userName=$1
  userPass=$2
  loopMode=$3
  pauseTime=$4
else
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <user name> <user password> <loop mode[Y|N]> <pause> "
  echo " "
  echo " e.g. "
  echo "     $product.sh root pa$$w0rD"
  echo "     $product.sh root pa$$w0rD N"
  echo "     $product.sh root pa$$w0rD Y"
  echo "     $product.sh root pa$$w0rD Y 5 "
  echo " "
  exit 1
fi


#-----------------------------------
# Initialise ..
#-----------------------------------
source commonFun
currDir=`pwd`


#-----------------------------------
#Run ..
#-----------------------------------
loopBreaker=0
while [ 1 -ne $loopBreaker ];
do
  fnRunMyTapUnitTests $cfgAPI/create $cfgUnitTestSuffix | morepause $pauseTime
  fnRunMyTapUnitTests $cfgAPI/delete $cfgUnitTestSuffix | morepause $pauseTime
  fnRunMyTapUnitTests $cfgAPI/get $cfgUnitTestSuffix | morepause $pauseTime
  fnRunMyTapUnitTests $cfgAPI/update $cfgUnitTestSuffix | morepause $pauseTime
  fnRunMyTapUnitTests $cfgAPI/register $cfgUnitTestSuffix | morepause $pauseTime
  fnRunMyTapUnitTests $cfgAPI/util $cfgUnitTestSuffix | morepause $pauseTime
  if [[ "$loopMode" != [yY] ]];then
    loopBreaker=1
  fi
done


#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
