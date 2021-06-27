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
WD01=("WDC WD" "40" "60" "EDAZ")            #3 WD Elements(3.5) 4TB 6TB
WD02=("WDC WD" "20" "30" "40" "60" "EFAX")  #1 WD Red(3.5) 2TB 3TB 4TB 6TB  
WD03=("WDC WD" "60" "EMAZ")                 #3 WD Elements(3.5) 6TB
WD04=("WDC WD" "20" "30" "40" "60" "EZAZ")  #1 WD Blue(3.5) 2TB 3TB 4TB 6TB  
WD05=("WDC WD" "5000" "LPSX")               #2 WD Black(2.5) 500TB
WD06=("WDC WD" "9000" "LPZX")               #1 WD Blue(2.5) 900GB
WD07=("WDC WD" "40" "NPZZ")                 #3 WD Blue(2.5) 4TB
WD08=("WDC WD" "10" "SPSX")                 #1 WD Black(2.5) 1TB
WD09=("WDC WD" "10" "SPWX")                 #3 WD Blue(2.5) 1TB
WD10=("WDC WD" "10" "20" "SPZX")            #1 WD Blue(2.5) 1TB 2TB

# Seagate
ST01=("ST" "6000" "8000" "AS0002")          #1 Archive(3.5) 6TB 8TB 
ST02=("ST" "8000" "AS0003")                 #1 Exos (3.5) 8TB 
ST03=("ST" "5000" "AS0011")                 #1 Archive(3.5) 5TB
ST04=("ST" "5000" "DM000")                  #1 Desktop(3.5) 5TB
ST05=("ST" "5000" "6000" "DM003")           #1 Barracuda(3.5) 6TB #1 5TB
ST06=("ST" "4000" "8000" "DM004")           #1 Barracuda(3.5) 8TB 4TB
ST07=("ST" "2000" "DM005")                  #1 Barracuda(3.5) 4TB 2TB
ST08=("ST" "3000" "DM007")                  #1 Barracuda(3.5) 3TB
ST09=("ST" "2000" "DM008")                  #1 Barracuda(3.5) 2TB
ST10=("ST" "5000" "LM000")                  #1 Barracuda(2.5) 5TB
ST11=("ST" "2000" "LM015")                  #1 Barracuda(2.5) 2TB
ST12=("ST" "3000" "4000" "LM024")           #1 Barracuda(2.5) 4TB 3TB
ST13=("ST" "500" "LM030")                   #1 Barracuda(2.5) 500GB
ST14=("ST" "500" "LM034")                   #1 Barracuda(2.5) 500GB
ST15=("ST" "1000" "LM048")                  #1 Barracuda(2.5) 1TB
ST16=("ST" "1000" "LM049")                  #1 Barracuda(2.5) 1TB
ST17=("ST" "8000" "VX002")                  #2 Skyhawk(3.5) 8TB
ST18=("ST" "4000" "VX005")                  #2 Skyhawk(3.5) 4TB
ST19=("ST" "4000" "VX005")                  #2 Skyhawk(3.5) 4TB
ST20=("ST" "1000" "8000" "VX008")           #1,#2 Skyhawk(3.5) 8TB, 1TB 
ST21=("ST" "6000" "VX010")                  #2 Skyhawk(3.5) 2TB
ST22=("ST" "6000" "VX011")                  #2 Skyhawk(3.5) 6TB
ST23=("ST" "2000" "VX012")                  #2 Skyhawk(3.5) 6TB
ST24=("ST" "4000" "VX013")                  #2 Skyhawk(3.5) 4TB
ST25=("ST" "2000" "VX015")                  #2 Skyhawk(3.5) 2TB
ST26=("ST" "3000" "VX016")                  #2 Skyhawk(3.5) 2TB
ST27=("ST" "3000" "VX017")                  #2 Skyhawk(3.5) 2TB

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
for k in {01..27}; do
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
  for k in {01..27}; do
    DetectSMR ST"$k"
  done

# DetectSMR TEST  
  echo
fi
