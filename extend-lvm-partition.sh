#!/bin/bash

if [[ "$#" -ne 3 ]]; then
  echo "$0: blockDeviceSize spaceToUse deviceEndName"
  echo ""
  echo "blockDeviceSize: the integer of the size in Gigabytes of the new disk"
  echo "spaceToUse: the integer of the space that should be utilized from the new disk"
  echo "deviceEndName: The end string of the logical volume that you want to extend in space"
  echo ""
  echo "Example:"
  echo "$0: 50 45 var"
  exit 1
fi

size="$1"
increaseSize="$2"
partition="$3"

newDisk=$(lsblk -o SIZE,NAME | grep "[[:space:]]${size}G[[:space:]]" | tail -n 1 | awk '{print $2}')
diskPath="/dev/${newDisk}"
vg=$(vgdisplay | grep 'VG Name' | awk '{print $3}')
lv=$(lvdisplay | grep 'LV Path' | grep -i "${partition}$" | awk '{print $3}')

if [[ -z "${newDisk}" ]]; then
  echo "Host $(hostname -s) did not get a new ${size}GB disk"
  exit 1
 fi
 
 pvcreate "${diskPath}"
 
 if [[ "$?" -eq 5 ]]; then
  echo "Disk ${newDisk} has already been initialized. Now exiting"
  exit 1
 fi
 
 vgextend "${vg}" "${diskPath}"
 lvresize --resizefs -L +${increaseSize}G "${lv}"
