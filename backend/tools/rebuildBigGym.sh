#!/bin/bash
#---------------------------------------------------------------------------------------------------------------------
# Purpose : Convenience tool to quickly (re-)build and load BIGGYM
#
# Author      Date         Version     Comments
# ------      ----------   -------     --------
# Fraioli     2016-01-31       1.0     Created
#---------------------------------------------------------------------------------------------------------------------


#-----------------------------------------------
# FUNCTIONS #
#-----------------------------------------------

#----------------------------------------------------------
#----------------------------------------------------------




#########################
# Main
#########################
tput clear

# Customisable persistent variables ..
cfgProjectRoot="$HOME/code/github/captainkirk854/project-BigGym/backend"


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
cd $cfgProjectRoot/ddl/BIGGYM > /dev/null 2>&1
mysqlb.sh $userName $userPass \*.ddl
mysqlb.sh $userName $userPass \*.sql

#--------------------------
# Functions and Stored Procedures ..
#--------------------------
echo "Building: Functions and Stored Procedures .."
cd $cfgProjectRoot/sql/BIGGYM/code/util > /dev/null 2>&1
mysqlb.sh $userName $userPass \*.sql
cd $cfgProjectRoot/sql/BIGGYM/code/api > /dev/null 2>&1
mysqlb.sh $userName $userPass \*.sql

#--------------------------
# Sample Data ..
#--------------------------
echo "Building: Sample Data .."
cd $cfgProjectRoot/data/sample/BIGGYM/using_sprocs > /dev/null 2>&1
mysqlb.sh $userName $userPass sample_set1


#-----------------------------------
# Happy end ..
#-----------------------------------
cd $currDir > /dev/null 2>&1
echo ""
