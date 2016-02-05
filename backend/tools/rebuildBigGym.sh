#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Convenience tool to quickly (re-)build and load BIGGYM
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-01-31       1.0     Created
# Fraioli     2016-02-05       1.1     Compacted
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
fnIngest()
#----------------------------------------------------------
{
 dir=$1
 suffix=$2

 cd $dir > /dev/null 2>&1
 mysqlb.sh $userName $userPass \*.$suffix
 cd - > /dev/null 2>&1
}
#----------------------------------------------------------




#########################
# Main
#########################
tput clear

# Customisable persistent variables ..
cfgProjectRoot="$HOME/code/github/captainkirk854/project-BigGym/backend/BIGGYM"
cfgDDL="$cfgProjectRoot/ddl"
cfgAPI="$cfgProjectRoot/api"
cfgDATA="$cfgProjectRoot/data"
cfgSAMPLE="$cfgDATA/sample"


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
# Objects ..
#--------------------------
echo "Building: Objects .."
fnIngest $cfgDDL ddl
fnIngest $cfgDDL sql

#--------------------------
# Functions and Stored Procedures ..
#--------------------------
echo "Building: Functions and Stored Procedures .."
fnIngest $cfgAPI/create sql
fnIngest $cfgAPI/delete sql
fnIngest $cfgAPI/get sql
fnIngest $cfgAPI/update sql
fnIngest $cfgAPI/util sql

#--------------------------
# Sample Data ..
#--------------------------
echo "Building: Sample Data .."
fnIngest $cfgSAMPLE/using_sprocs mysql

#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
