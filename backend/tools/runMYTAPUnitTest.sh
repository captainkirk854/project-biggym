#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Convenience tool to run single unit test for MYSQL programmatic entities
#
# Dependencies: 
#               > commonFun
#               > mysqlb.sh
#               > morepause
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-02-13       1.0     Created
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
fnRunMyTapUnitTest()
#----------------------------------------------------------
{
 fullPath=$1
#
# Process test and colourise the resultant output accordingly ..
 if [ -f $fullpath ];then
   echo ""
   echo $sep
   echo "USING [$fullPath] FILE .."
   echo $sep
   cd $dir > /dev/null 2>&1
   # Run test and colour the output stream with different colour formats according to string ..
   mysqlb.sh $userName $userPass $fullPath -suppress \
                                                      | GREP_COLOR=$colourTestFail    egrep --colour=always "$grepTestFail" \
                                                      | GREP_COLOR=$colourTestPass    egrep --colour=always "$grepTestPass" \
                                                      | GREP_COLOR=$colourTestWarning egrep --colour=always "$grepTestWarning" \
                                                      | GREP_COLOR=$colourCoreErrors  egrep --colour=always "$grepCoreErrors" \
                                                      | GREP_COLOR=$colourOtherThings egrep --colour=always "$grepOtherThings" 
 else
   echo "[$fullpath] not found!"
 fi
}
#----------------------------------------------------------




#########################
# Main
#########################
tput clear

# Customisable persistent variables ..


#-----------------------------------
# Assign input argument(s) ..
#-----------------------------------
product=`basename $0 .sh`

# Assign input arguments ..
if ([ $# -ge 3 ]);then
  userName=$1
  userPass=$2
  testFullPath=$3
  loopMode=$4
  pauseTime=$5
else
  echo " "
  echo "USAGE ERROR !"
  echo " $product.sh <user name> <user password> <file path> <loop mode[Y|N]> <pause> "
  echo " "
  echo " e.g. "
  echo "     $product.sh root pa$$w0rD /tmp/mytest.sfx"
  echo "     $product.sh root pa$$w0rD /tmp/mytest.sfx N"
  echo "     $product.sh root pa$$w0rD /tmp/mytest.sfx Y"
  echo "     $product.sh root pa$$w0rD /tmp/mytest.sfx Y 5"
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
  fnRunMyTapUnitTest $testFullPath | morepause $pauseTime
  if [[ "$loopMode" != [yY] ]];then
    loopBreaker=1
  fi
done

#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
