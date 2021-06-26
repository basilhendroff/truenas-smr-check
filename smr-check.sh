#!/bin/bash

DP=7
TP=10
SP=17

cols="%${DP}s | %${TP}s | %${SP}s |\n"

# Get list of disks and create arrays
midclt call disk.query | jq -S '.[] | {devname: .devname, model: .model, serial: .serial}' > tmp.json

declare -a "DEV=($(<tmp.json jq -r '.devname | @sh'))"
declare -a "MOD=($(<tmp.json jq -r '.model | @sh'))"
declare -a "SN=($(<tmp.json jq -r '.serial | @sh'))"

rm tmp.json

function check() {
name=$1[@]

SMR=("${!name}")
# Across all disks
for ((i=0;i<${#DEV[@]};i++)); do

# if a disk is a WD
#  if [[ "${MOD[$i]:0:6}" == "${SMR[0]}" ]]; then
  if [[ "${MOD[$i]}" == *"${SMR[0]}"* ]]; then
    TMP[$i]="${MOD[$i]#*" "}"
    TMP[$i]="${TMP[$i]%%-*}"

# if it is a suspect model
    if [[ "${TMP[$i]}" == *"${SMR[-1]}"* ]]; then
      for ((j=1;j<$((${#SMR[@]}-1));j++)); do

# if it is a suspect size
        if [[ "${TMP[$i]}" == *"${SMR[j]}"* ]]; then
          if [[ -z "$2" ]]; then  
            printf "$cols" "${DEV[$i]}" "${TMP[$i]}" "${SN[$i]}"
          else
            flag=1
          fi
        fi
      done
    fi
#    printf "%5s %10s %20s\n" "${DEV[$i]}" "${TMP[$i]}" "${SN[$i]}"
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
SMR01=("WDC WD" "20" "30" "40" "60" "EFAX")	#1
SMR02=("WDC WD" "20" "30" "40" "60" "EZAZ")	#1
SMR03=("WDC WD" "10" "20" "SPZX")		#1
SMR04=("WDC WD" "10" "SPSX")			#1
SMR05=("WDC WD" "9000" "LPZX")			#1
SMR06=("WDC WD" "5000" "LPSX")			#2
SMR07=("WDC WD" "40" "60" "EDAZ")		#3
SMR08=("WDC WD" "60" "EMAZ")			#3
SMR09=("WDC WD" "10" "SPWX")			#3
SMR10=("WDC WD" "40" "NPZZ")			#3




SMRX=("WDC WD" "30" "EFRX")

flag=0

check SMR01 test
check SMR02 test
check SMR03 test
check SMR04 test
check SMR05 test
check SMR06 test
check SMR07 test
check SMR08 test
check SMR09 test
check SMR10 test

check SMRX test

if [[ "$flag" == 0 ]]; then
  echo
  echo -e "\e[1;32mNo known WD SATA SMR disks detected.\e[0m"
  echo
else
  echo
  echo -e "\e[1;31mKnown WD SATA SMR disk(s) detected.\e[0m"
  echo

  printf "$cols" "Device" "Model" "Serial Number" 
  s=$(printf "%-$((DP+TP+SP+8))s" "-")
  echo "${s// /-}"

  check SMR01
  check SMR02
  check SMR03
  check SMR04
  check SMR05
  check SMR06
  check SMR07
  check SMR08
  check SMR09
  check SMR10

  check SMRX
fi
