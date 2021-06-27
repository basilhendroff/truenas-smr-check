#!/bin/bash

# Table column widths
DeviceWidth=7
ModelWidth=12
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
# Initialise
name=$1[@]
SMR=("${!name}")
unset TMP

# For each disk
for ((i=0;i<${#Device[@]};i++)); do
# Is the manufacturer in the database?
  if [[ "${Model[$i]:0:6}" == *"${SMR[0]}"* ]]; then
# If so, add the trimmed model name to a temporary array  
    TMP[$i]="${Model[$i]#*" "}"
    TMP[$i]="${TMP[$i]%%-*}"
# Based on the model suffix...
    if [[ "${TMP[$i]}" == *"${SMR[-1]}"* ]]; then
      for ((j=1;j<$((${#SMR[@]}-1));j++)); do
# Is the model in the SMR database?
        if [[ "${TMP[$i]}" == *"${SMR[j]}"* ]]; then
          if [[ -z "$2" ]]; then  
            printf "$fmt" "${Device[$i]}" "${TMP[$i]}" "${Serial[$i]}"
          else
            f=1
          fi
        fi
      done
    fi
  fi
done
}

# The SMR database is made up of a number of arrays (sorted by suffix below)
#
# References:
# 1. https://www.truenas.com/community/resources/list-of-known-smr-drives.141/
# 2. https://nascompares.com/answer/list-of-wd-cmr-and-smr-hard-drives-hdd/
# 3. https://hddscan.com/blog/2020/hdd-wd-smr.html
#
# Western Digital
WD01=("WDC WD" "40" "60" "EDAZ")            #3
WD02=("WDC WD" "20" "30" "40" "60" "EFAX")  #1
WD03=("WDC WD" "60" "EMAZ")                 #3
WD04=("WDC WD" "20" "30" "40" "60" "EZAZ")  #1
WD05=("WDC WD" "5000" "LPSX")               #2
WD06=("WDC WD" "9000" "LPZX")               #1
WD07=("WDC WD" "40" "NPZZ")                 #3
WD08=("WDC WD" "10" "SPSX")                 #1
WD09=("WDC WD" "10" "SPWX")                 #3
WD10=("WDC WD" "10" "20" "SPZX")            #1

# Seagate
ST01=("ST" "6000" "8000" "AS0002")          #1
ST02=("ST" "8000" "AS0003")                 #1
ST03=("ST" "5000" "AS0011")                 #1
ST04=("ST" "5000" "DM000")                  #1
ST05=("ST" "5000" "6000" "DM003")           #1
ST06=("ST" "4000" "8000" "DM004")           #1
ST07=("ST" "2000" "DM005")                  #1
ST08=("ST" "3000" "DM007")                  #1
ST09=("ST" "2000" "DM008")                  #1
ST10=("ST" "5000" "LM000")                  #1
ST11=("ST" "2000" "LM015")                  #1
ST12=("ST" "3000" "4000" "LM024")           #1
ST13=("ST" "1000" "LM048")                  #1
ST14=("ST" "8000" "VX002")                  #2
ST15=("ST" "4000" "VX005")                  #2
ST16=("ST" "2000" "VX007")                  #1
ST17=("ST" "1000" "8000" "VX008")           #1, #2
ST18=("ST" "6000" "VX010")                  #2
ST19=("ST" "6000" "VX011")                  #2
ST20=("ST" "2000" "VX012")                  #2
ST21=("ST" "4000" "VX013")                  #2
ST22=("ST" "2000" "VX015")                  #2
ST23=("ST" "3000" "VX016")                  #2
ST24=("ST" "3000" "VX017")                  #2

# To test this script when you have no SMR disks, configure and temporarily uncomment one of the the TEST arrays below with a valid CMR disk on your system. 
# TEST=("WDC WD" "30" "EFRX")
# TEST=("ST" "6000" "VN0041")
# Now uncomment the TEST lines below (there should bbe two of them), and run the script. Remeber to comment oall TEST lines again when you've finished.

# Quiet detection phase. If an SMR disk is detected flag f will be set.
f=0

# Detect Western Digital SMR disks
for k in {01..10}; do
  DetectSMR WD"$k" q
done

# Detect Seagate SMR disks
for k in {01..24}; do
  DetectSMR ST"$k" q
done

# DetectSMR TEST q

# If the flag f is still unset, no SMR disk was detected. :)
if [[ "$f" == 0 ]]; then
  echo
  echo -e "\e[1;32mNo known SATA SMR disks detected.\e[0m"
  echo
else
# otherwise, one or more SMR disks were detected so diplay all SMR disks in a table :(
  echo
  echo -e "\e[1;31mKnown SATA SMR disk(s) detected.\e[0m"
  echo

  fmt="%${DeviceWidth}s | %${ModelWidth}s | %${SerialWidth}s |\n"
  
  printf "$fmt" "Device" "Model" "Serial Number" 
  s=$(printf "%-$((DeviceWidth+ModelWidth+SerialWidth+8))s" "-")
  echo "${s// /-}"

# Detect Western Digital SMR disks
  for k in {01..10}; do
    DetectSMR WD"$k"
  done

# Detect Seagate SMR disks
  for k in {01..24}; do
    DetectSMR ST"$k"
  done

# DetectSMR TEST  
  echo
fi
