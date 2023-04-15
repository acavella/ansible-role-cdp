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
   # loop through array and download CRL
   for i in "${CRL_SOURCE[@]}" 
   do 
      local temp_file=$(mktemp)
      curl -k -s ${i} -o ${temp_file}
      # check for existence of file
      if [ ! -e ${temp_file} ]
      then 
         echo "missing file, exiting"
         exit 1 # exit due to download fail/missing file
      fi
      # check for zero byte file, 
      if [ -s ${temp_file} ]
      then
         echo "zero byte file, exiting"
         exit 1 # exit due to zero byte file
      fi
      # parse with openssl, retrieve subject (cn)
      local subject=$(openssl crl -inform DER -issuer -noout -in ${temp_file} -nameopt multiline |\ 
      grep commonName | awk '{ for (i=3; i<=NF; i++) printf("%s ",$i) }END{ print"" }')
      # remove spaces from subject
      local filename=${subject//[[:blank:]]/}
      # copy valid crl to www and rename
      echo "crl valid, moving to httpd"
      mv ${temp_file} ${PUB_WWW}/${filename}.crl
   done
}

get_crl_list() {
   crl_list=$(mktemp)
   echo "SOURCE,CRL ADDRESS" >> ${crl_list}
   # loop through array and download crl
   for i in "${CRL_SOURCE[@]}"
   do
      local temp_file=$(mktemp)
      curl -k -s ${i} -o ${temp_file}
      # parse with openssl, retrieve subject (cn)
      local subject=$(openssl crl -inform DER -issuer -noout -in ${temp_file} -nameopt multiline |\ 
      grep commonName | awk '{ for (i=3; i<=NF; i++) printf("%s ",$i) }END{ print"" }')
      # remove spaces from subject
      local filename=${subject//[[:blank:]]/}
      echo "${i},http://${REMOTE_SERVER}/${filename}.crl" >> ${crl_list}
      rm -rf ${temp_file}
   done
   column -t -s',' ${crl_list}
   rm -rf ${crl_list}
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

if [[ ${2} == "--print-config" ]]; then
   get_crl_list
   exit 0
else
   main
   exit 0 # clean exit on success
fi

