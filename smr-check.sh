#!/bin/bash

# Table column widths
DeviceWidth=7
ModelWidth=10
SerialWidth=17

# Gather disk information and populate arrays
midclt call disk.query | jq -S '.[] | {devname: .devname, model: .model, serial: .serial}' > tmp.json

declare -a "Device=($(<tmp.json jq -r '.devname | @sh'))"
declare -a "Model=($(<tmp.json jq -r '.model | @sh'))"
declare -a "Serial=($(<tmp.json jq -r '.serial | @sh'))"

rm tmp.json

# Detection engine
# $1 = Name of array
# $2 = Any character to trigger silent mode
function DetectSMR() {
name=$1[@]
SMR=("${!name}")
# For each disk
for ((i=0;i<${#Device[@]};i++)); do
# Is it a WD disk?
  if [[ "${Model[$i]}" == *"${SMR[0]}"* ]]; then
# If so, Add the trimmed model name to a temporary array  
    TMP[$i]="${Model[$i]#*" "}"
    TMP[$i]="${TMP[$i]%%-*}"
# Based on the model suffix...
    if [[ "${TMP[$i]}" == *"${SMR[-1]}"* ]]; then
      for ((j=1;j<$((${#SMR[@]}-1));j++)); do
# Look for an SMR model
        if [[ "${TMP[$i]}" == *"${SMR[j]}"* ]]; then
          if [[ -z "$2" ]]; then  
            printf "$fmt" "${Device[$i]}" "${TMP[$i]}" "${Serial[$i]}"
          else
            f=1
          fi
        fi
      done
    fi
#    printf "%5s %10s %20s\n" "${Device[$i]}" "${TMP[$i]}" "${Serial[$i]}"
  fi
done
}

# Define SMR arrays
#
# References:
# 1. https://www.truenas.com/community/resources/list-of-known-smr-drives.141/
# 2. https://nascompares.com/answer/list-of-wd-cmr-and-smr-hard-drives-hdd/
# 3. https://hddscan.com/blog/2020/hdd-wd-smr.html
#
WD01=("WDC WD" "20" "30" "40" "60" "EFAX")	#1
WD02=("WDC WD" "20" "30" "40" "60" "EZAZ")	#1
WD03=("WDC WD" "10" "20" "SPZX")		        #1
WD04=("WDC WD" "10" "SPSX")			            #1
WD05=("WDC WD" "9000" "LPZX")			          #1
WD06=("WDC WD" "5000" "LPSX")			          #2
WD07=("WDC WD" "40" "60" "EDAZ")		        #3
WD08=("WDC WD" "60" "EMAZ")			            #3
WD09=("WDC WD" "10" "SPWX")			            #3
WD10=("WDC WD" "40" "NPZZ")			            #3

# Quiet detection phase. If an SMR disk is detected flag f will be set to 1.
f=0

DetectSMR WD01 q
DetectSMR WD02 q
DetectSMR WD03 q
DetectSMR WD04 q
DetectSMR WD05 q
DetectSMR WD06 q
DetectSMR WD07 q
DetectSMR WD08 q
DetectSMR WD09 q
DetectSMR WD10 q

# If the flag f is still zero, no SMR disk was detected. :)
if [[ "$f" == 0 ]]; then
  echo
  echo -e "\e[1;32mNo known WD SATA SMR disks detected.\e[0m"
  echo
else
# otherwise, one or more SMR disks were detected so diplay all SMR disks in a table :(
  echo
  echo -e "\e[1;31mKnown WD SATA SMR disk(s) detected.\e[0m"
  echo

  fmt="%${DeviceWidth}s | %${ModelWidth}s | %${SerialWidth}s |\n"
  
  printf "$fmt" "Device" "Model" "Serial Number" 
  s=$(printf "%-$((DeviceWidth+ModelWidth+SerialWidth+8))s" "-")
  echo "${s// /-}"

  DetectSMR WD01
  DetectSMR WD02
  DetectSMR WD03
  DetectSMR WD04
  DetectSMR WD05
  DetectSMR WD06
  DetectSMR WD07
  DetectSMR WD08
  DetectSMR WD09
  DetectSMR WD10
  
  echo
fi
