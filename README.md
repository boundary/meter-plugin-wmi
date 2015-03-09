Boundary WMI Plugin
--------------------------
Extracts metrics from a WMI instances.

### Prerequisites

|     OS    | Linux | Windows | SmartOS | OS X |
|:----------|:-----:|:-------:|:-------:|:----:|
| Supported |       |    v    |         |      |


|  Runtime | node.js | Python | Java | LUA |
|:---------|:-------:|:------:|:----:|:---:|
| Required |         |       |       |  +  |


- [How to install Luvit (LUA)?](https://luvit.io/) 

### Plugin Setup

#### Installation of Luvit to test plugin

1. Compile Luvit from SRC

     ```Make.bat``` for Windows ```Makefile``` for nix-based OS
	 
2. You may use boundary-meter. Before params.json should be changed for choosen instances.

	```boundary-meter index.lua```

### Plugin Configuration Fields
|Field Name|Description                                     |
|:-------|:-------------------------------------------------|
|Source  |display name                                      |


### Metrics Collected

|Metric Name                                    |Description                                                                                                          |
|:----------------------------------------------|:--------------------------------------------------------------------------------------------------------------------|
|WMI - Perc Proc Time                           |Percentage of the time the processor is busy doing non-idle threads                                                  |
|WMI - Perc Disks Time                          |Percentage of the time the selected physical disks are busy servicing read or write requests                         |
|WMI - Available Bytes                          |Amount of memory immediately available for allocation to a process or for system use                                 |
|WMI - Swap Rate                                |A high rate of memory operations involving disk swap are symptoms of memory shortage and affects system performance  |
|WMI - disks space                              |FreeSpace is the available storage space in bytes on the specified logical disk                                      |
|WMI - network receiving                        |BytesReceivedPersec are the current transmission rates for the specified adapter                                     |
|WMI - network sending                          |BytesSentPersec are the current transmission rates for the specified adapter                                         |
|WMI - Connections                              |ConnectionEstablished, seen in the code above, is the current number of Established connections, inbound and outbound|
