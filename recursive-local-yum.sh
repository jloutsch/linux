#!/bin/bash

if [[ "$#" -eq 0 ]]; then
  echo "Usage: $0 package_name ..."
  exit 1
 fi
 
 # Only root can run this script
 if [[ "$EUID" != "0" ]]; then
   echo "You must be root to run this script."
   exit 1
 fi
 
 if ! which yumdownloader > /dev/null; then
   echo "Script requires yum-utils to be installed"
   exit 1
 fi
 
package_deps=$(sort <(sed -e 's/ [| \\\_]\+\|-[[:digit:]]\+..*\|[[:digit:]]\://g' <(repoquery --tree-requires $@ 2> /dev/null)) | uniq)

yumdownloader $package_deps
