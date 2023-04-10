#!/usr/bin/env bash

# CDP Sync: Pulls CRL files from remote server and hosts them locally
# Version: 2020114001
# POC: Tony Cavella (cavella_tony@bah.com)
# Description: This script uses curl to retrieve CRL files from a 
# remote host (CA), renames the file appropriately and serves it 
# via HTTPd.
#
# Usage: Script is executed automatically via a root cronjob every 15
# minutes and can be alternately executed manually.  All user configurable
# variables are found in cdp.conf
#
# User Variables:
#   CRL_SOURCE[@] an array that defines CRL locations on the CA for retrieval
#   CRL_NAME[@] an array that defines the CRL name to be served
#   PUB_WWW defines the www directory used to serve CRLs
#   REMOTE_SERVER address used to verify connectivity, usually remote CA
#
# -e option instructs bash to immediately exit if any command has a non-zero exit status
# -u option instructs bash to exit on unset variables

set -e
set -u

## VARIABLES
# As much data is stored in variables for maintainability.
# GLOBAL variables are written in CAPS
# Local variables are written in lowercase

# Base Directories
__DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Script Variables
DTG=$(date '+%Y%m%d-%H%M')

# External / User Variables
source ${__DIR}/updatecdp.conf

## FUNCTIONS

check_connectivity() {
   /bin/ping -c 1 ${REMOTE_SERVER} > /dev/null 2>&1;
   local ping_exit=$?
   if [ ${ping_exit} -eq 0 ]
   then
      echo "ca found"
   else
      echo "unable to ping ca, exiting"
      exit 1
   fi
}

download_crl() {
   # local, named variables
   local count=0
   echo "counter reset"
   local tmp_dir=$(mktemp -d /tmp/cdp.XXXXXXX)
   echo  "temp directory created"

   # loop through array and download CRL
   for i in "${CRL_SOURCE[@]}" 
   do 
      curl -k -s ${i} -o ${tmp_dir}/${CRL_NAME[${count}]}
      # check for existence of file
      if [ ! -e ${tmp_dir}/${CRL_NAME[${count}]} ]
      then 
         echo "missing file, exiting"
         exit 1 # exit due to download fail/missing file
      fi
      # check for zero byte file, copy valid crl to www
      if [ -s ${tmp_dir}/${CRL_NAME[${count}]} ]
      then 
         echo "crl valid, moving to httpd"
         mv ${tmp_dir}/${CRL_NAME[${count}]} ${PUB_WWW}
      else
         echo "zero byte file, exiting"
         exit 1 # exit due to zero byte file
      fi
   ((++count)) # increment counter
   done

   # clean up temp files
   rm -rf ${tmp_dir}
}

fix_permissions() {
   chown apache:apache ${PUB_WWW} -R
   restorecon -r ${PUB_WWW}
   echo "restore permissions"
}

main() {
   check_connectivity
   download_crl  
   fix_permissions
}

main
exit 0 # clean exit on success