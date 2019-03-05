#!/bin/bash
cdnroot=$1
owner=$2
group=$3

if [[ "$#" -ne 3 ]]; then
  echo "Usage: $0 path_to_cdn_root file_owner group_owner"
  echo "Tested on RedHat 7 with Bash version 4.2.46"
  echo "WARNING: this is a highly dangerous operation. Backup your repodata directories before continuing"
  exit 1
fi

rpm -q createrepo > /dev/null 2>&1
if [[ "$?" -ne 0 ]]; then
  echo "You must have the createrepo package installed to run this script"
  exit 1
fi

for directory in $(find "${cdnroot}" -type d -name "repodata"); do
  # We want to see if group metadata exists for this repository. If it does,
  # select the latest metadata file, and use it in the createrepo command.
  repodataFiles=$(ls -1t ${directory})
  compsFiles=()
  for repodataFile in ${repodataFiles[@]}; do
    if [[ "${repodataFile}" =~ .*comps.*\.xml$ ]]; then
      compsFiles+=("${directory}/${repodataFile}")
    fi
  done
  
  # If no group files exist, run createrepo with no group option
  if [[ ${#compsFiles[@]} -eq 0 ]]; then
    echo "Creating the repository ${directory} with NO group files"
    createrepo "$(dirname ${directory})" && chown -R "${owner}":"${group}" "$(dirname ${directory})"
  else
    # Create the repo file with the newest found group file
    echo "Creating the repository ${directory} with group file ${compsFiles[0]}"
    createrepo --groupfile "${compsFiles[0]}" "$(dirname ${directory})" && chown -R "${owner}":"${group}" "$(dirname ${directory})"
  fi
  
  # We don't need a regex for updateinfo files, so we can just 
  # map the output of 'ls' into an array with the 'mapfile' utility
  mapfile -t updateFiles < <(ls -1t ${directory}/*updateinfo* 2> /dev/null)
  
  # If we found an update file, select the newest one and modify the newly created repo
  if [[ "${#updateFiles[@]}" -gt 0 ]]; then
    echo "Updating the repository ${directory} with updateinfo ${updateFiles[0]}"
    modifyrepo "${updateFiles[0]}" "${directory}"
  fi
done
 
