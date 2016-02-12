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
 pause=$3
#
 # Define some colour codes to use ..
 fgRed=31
 fgYellow=32
 fgCyan=36
 fgLightyellow=93
 bgBlack=40
 bgWhite=47
 bgDefault=49
 bgLightred=101

 # Set colour for test failure result ..
 fg=$fgLightyellow
 bg=$bgLightred
 colourTestFail="01;$fg;$bg"
 grepTestFail='\b(not ok|Failed|Looks like you failed)\b|$'

 # Set colour for test pass result ..
 fg=$fgCyan
 bg=$bgBlack
 colourTestPass="01;$fg;$bg"
 grepTestPass='\b(ok)\b|$'

 # Set colour for test warnings ..
 fg=$fgRed
 bg=$bgBlack
 colourTestWarning="01;$fg;$bg"
 grepTestWarning='\b(Looks like you planned|test but ran)\b|$'

 # Set colour for core errors ..
 fg=$fgRed
 bg=$bgWhite
 colourCoreErrors="01;$fg;$bg"
 grepCoreErrors='\b(ERROR|does not exist)\b|$'

 # Other things ..
 fg=$fgLightyellow
 bg=$bgDefault
 colourOtherThings="01;$fg;$bg"
 grepOtherThings='\b(PROCESSING|__completed)\b|$'
 
 sep="-------------------------------------------------------------------------------------------------------------"

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

   # pause ..
   if [ -n "$pause" ];then
     sleep $pause
   fi
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
  echo "     $product.sh root pa$$w0rD  "
  echo "     $product.sh root pa$$w0rD 5 "
  echo " "
  exit 1
fi

currDir=`pwd`

#Run ..

#--------------------------
# Testing start ..
#--------------------------
echo "Testing: Functions and Stored Procedures .."
fnRunMyTapUnitTest $cfgAPI/create $cfgUnitTestSuffix $pauseTime
fnRunMyTapUnitTest $cfgAPI/delete $cfgUnitTestSuffix $pauseTime
fnRunMyTapUnitTest $cfgAPI/get $cfgUnitTestSuffix $pauseTime
fnRunMyTapUnitTest $cfgAPI/update $cfgUnitTestSuffix $pauseTime
fnRunMyTapUnitTest $cfgAPI/util $cfgUnitTestSuffix $pauseTime

#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
