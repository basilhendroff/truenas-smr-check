# truenas-smr-check
A bash script to check for known WD SATA SMR disks on a TrueNAS server.

## How to Use
Download the repository to a convenient directory on your TrueNAS system by changing to that directory and running git clone https://github.com/basilhendroff/truenas-smr-check. Then change into the newly created directory and run the script `./smr-check.sh`. The script ahouldn't take very long to run. The script does not create or leave anything behind once its run. If SMR disks are detected, the device name, WD SATA disk model and disk serial number of each disk is displayed in a table e.g.
```

Known WD SATA SMR disk(s) detected.

 Device |      Model |     Serial Number |
------------------------------------------
   ada3 |   WD30EFAX |   WD-xxxxxxxxxxxx |
```

## Scope
At this stage, only known WD SATA SMR disks are checked for.

The database of known SATA SMR disks has been compiled from the following resources:
1. [List of known SMR drives](https://www.truenas.com/community/resources/list-of-known-smr-drives.141/)
2. [NAS Compores: List Of WD CMR And SMR Hard Drives (HDD)](https://nascompares.com/answer/list-of-wd-cmr-and-smr-hard-drives-hdd/)
3. [HDDScan: What WD and HGST hard drives are SMR?](https://hddscan.com/blog/2020/hdd-wd-smr.html)
