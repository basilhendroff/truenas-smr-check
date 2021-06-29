# truenas-smr-check
TrueCommand has a built-in check for known WD SMR drives on connected TrueNAS servers. However, if you don't use TrueCommand, you can still use this bash script to help you identify culprit drives. The script doesn't limit checks just to the WD NAS range of drives (RED), but extends this to any WD SMR drive listed in its database (BLUE, BLACK, Ultrastar, etc.). 

The latest version identifies known Seagate and Toshiba SMR drives as well.

## Status
This script will work with FreeNAS 11.3, and TrueNAS CORE 12.0 or later. Though untested, it may very well work with earlier version of FreeNAS 11.

## How to Use
Download the repository to a convenient directory on your TrueNAS system by changing to that directory and running `git clone https://github.com/basilhendroff/truenas-smr-check`. Then change into the newly created directory and run the script `./smr-check.sh`. The script should only take a few seconds to execute. The script is non-invasive and does not leave anything behind after it completes. If SMR drives are detected, the device name, drive model and serial number of each drive is displayed in a table e.g.
```

Known SMR drive(s) detected.

 Device |           Model |        Serial Number |
--------------------------------------------------
   ada0 |     ST8000VX008 |             xxxxxxxx |
   ada1 |    HDWL120EZSTA |         xxxxxxxxxxxx |
   ada3 |        WD30EFAX |     xxxxxxxxxxxxxxxx |
```
The script SMR database is updated whenever previously unidentified SMR drives surface. It's important therefore to always download and use the latest version of this script. 

## Scope
Western Digital, Seagate and Toshiba SMR drives are detected.

The database of known SMR drives has been compiled from the following sources:
1. [TrueNAS Community Resource: List of known SMR drives](https://www.truenas.com/community/resources/list-of-known-smr-drives.141/)
2. [NAS Compares: List Of WD CMR And SMR Hard Drives (HDD)](https://nascompares.com/answer/list-of-wd-cmr-and-smr-hard-drives-hdd/)
3. [HDDScan: What WD and HGST hard drives are SMR?](https://hddscan.com/blog/2020/hdd-wd-smr.html)

## Disclaimer
This script is useful for quickly identifying SMR drives known to the script. While every endeavour has been taken to include as many SMR drives as possible, be aware the SMR database within the script may not be complete. Therefore, you're advised not to rely solely on this script, but to confirm using other methods that the drives in your TrueNAS server are not using SMR technology.
