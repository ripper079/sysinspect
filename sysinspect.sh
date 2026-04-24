#!/bin/bash

# Author		-	Daniel Oikarainen
# Description	-	Deep system inspection tool that probes hardware devices and outputs a detailed system report to stdout
# Note			-	Sudo Privileges Needed
# Dependencies	-	dmidecode, lshw and hdparm, lscpu, find sed and awk
# Restrictions	-	Virtualized environments may provide incomplete or inaccurate results
# 				-	Limited support for multi-GPU configurations
#				-	Limited support for network-attached storage devices
#				-	Accurate GPU-related information is only guaranteed for discrete GPU configurations

clear
        
LINESTRING="";
SEARCH_STRING=""
FORMATTED_STRING=""


function createFiles()
{
	echo "Collecting data..."
	lshw -short >> file_lshw_short.tmp
	lshw -class display >> file_lshw_class_display.tmp;
	echo "done!!!"
	sleep 1
	clear
	
}

function deleteFiles()
{
	rm file_lshw_short.tmp
	rm file_lshw_class_display.tmp
}

function printCPUInfo()
{
    #Get CPU model
    echo ""
    echo "CPU"
    echo "---------------------------------------------------------------------------------"

	SEARCH_STRING=": "

    #Prints CPU name												#
    LINESTRING=`(cat /proc/cpuinfo | grep 'model name' | uniq)`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    echo -e "CPU Model:\t\t$FORMATTED_STRING"  

    #Prints Numbers of Cores											#
    LINESTRING=`(cat /proc/cpuinfo | grep 'cpu cores' | uniq)`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    echo -e "Core(s):\t\t$FORMATTED_STRING"
	   
    #Prints total numbers of threads for CPU							#
    LINESTRING=`(sudo dmidecode -t 4 | grep 'Thread Count')`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    echo -e "Thread(s):\t\t$FORMATTED_STRING"                  
                
	#Print CPU socket type
	LINESTRING=`(dmidecode -t 4 | grep 'Socket Designation')`
	FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
	echo -e "CPU Socket:\t\t$FORMATTED_STRING"	
	
	#Prints Current CPU speed										#
	LINESTRING=`(dmidecode -s processor-frequency)`	
	echo -e "CPU Speed:\t\t$LINESTRING"
		            
	#Prints Cache Level 1 Data                         				#
    LINESTRING=`(lscpu | grep 'L1d cache')`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "Cache L1(D):\t\t$FORMATTED_STRING"
    
    #Prints Cache Level 1 Instruction                  				#
    LINESTRING=`(lscpu | grep 'L1i cache')`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "Cache L1(I):\t\t$FORMATTED_STRING"
    
    #Prints Total L2 Cache											#
    LINESTRING=`(lscpu | grep 'L2 cache')`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "Cache L2:\t\t$FORMATTED_STRING"    
    
	#Prints L3 Cache												#
	LINESTRING=`(lscpu | grep 'L3 cache')`
	FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "Cache L3:\t\t$FORMATTED_STRING"
       
	echo ""
}


function printRAMInfo()
{
    echo ""
    echo "RAM"
	echo "---------------------------------------------------------------------------------"

	# Print Total RAM Capacity
	TOTAL_RAM_INSTALLED_COMPUTER=`(cat file_lshw_short.tmp | grep 'System Memory' | tr -s ' ' | cut -d' ' -f3- | cut -d ' ' -f1)`
	echo -e "Total RAM: \t\t$TOTAL_RAM_INSTALLED_COMPUTER"

	# Print individual RAM capacity 
	counter=1
	while read -r ram; do
		echo -e "RAM Module $counter:\t\t$ram"
		((counter++))
	done < <(cat file_lshw_short.tmp | awk '/DDR[2-5]/ {print $3}')
	
	#Print memory type 											#
	MEMORY_TYPE=`(dmidecode --type 17 | grep "Type:" | tr -d "\t" | grep -e "[^Type: Unknown]" | uniq | cut -d ":" -f 2 | cut -d " " -f 2-)`
	echo -e "Memory Type:\t\t$MEMORY_TYPE"
	
	# Print Memory Speed											#            
    SPEEDRAM=`(dmidecode -t 17 | grep "Speed" | tr -d "\t" | sort | uniq | grep -e "^Speed" | grep -e "[^Speed: Unknown]" | cut -d " " -f 2,3)`
    echo -e "Memory Speed:\t\t$SPEEDRAM"    
    
    echo ""
}

function printMotherBoardInfo()
{
	echo ""
	echo "Motherboard"
	echo "---------------------------------------------------------------------------------"
	
	SEARCH_STRING=": "
	
	#Print Manufactor board											#	
    MANUFACTURER_OF_MOTHERBOARD=`(dmidecode -s baseboard-manufacturer)`
    echo -e "Manufacturer:\t\t$MANUFACTURER_OF_MOTHERBOARD"
    
    #Print Product Name												#    
    PRODUCT_NAME=`(dmidecode -s baseboard-product-name)`    
    echo -e "Model:\t\t\t$PRODUCT_NAME"
    
    #Print BIOS Vendor												#    
    BIOS_VENDOR=`(dmidecode -s bios-vendor)`
    echo -e "Bios Vendor:\t\t$BIOS_VENDOR"    
    
    #Print BIOS Version												#    
    BIOS_VERSION=`(dmidecode -s bios-version)`
    echo -e "Bios Version:\t\t$BIOS_VERSION"
        
    #Print Form factor For RAM										#
    FORM_FACTOR=`(dmidecode -t 17 | grep "Form Factor" | tr -d "\t" | uniq | cut -d " " -f 3 | grep -v 'Unknown' | uniq)`
    echo -e "RAM Form Factor:\t$FORM_FACTOR"
    
    #Max Supported RAM Memory										#
    MAX_RAM=`(dmidecode -t 16 | grep "Maximum Capacity:" | tr -d "\t" | cut -d ":" -f 2 | cut -d " " -f 2-)`
    echo -e "MAX RAM Capacity:\t$MAX_RAM"
    
    #Print number of slots on motherboard							#
    RAM_SLOTS=`(dmidecode -t 16 | grep "Number Of Devices:" | tr -d "\t" | cut -d ":" -f 2 | cut -d " " -f 2)`    
    echo -e "RAM slots:\t\t$RAM_SLOTS"
    
    USED_RAM_SLOTS=`(dmidecode --type memory | sed -e 's/^[ \t]*//' | grep "^Size:" | grep "GB" | wc -l)`
    echo -e "Used RAM slots:\t\t$USED_RAM_SLOTS"            

    echo ""
}

function printGPUInfo()
{
	echo ""
	echo "Graphics Card"
	echo "---------------------------------------------------------------------------------"
	
	SEARCH_STRING=": "
	
	#Print Vendor Info												#
	LINESTRING=`(cat file_lshw_class_display.tmp | head -4 | tail -1)`
		
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "Vendor:\t\t\t$FORMATTED_STRING"
    
    # Get bus id for VGA controller
    IDBUS=`(lspci | grep VGA | cut -d " " -f 1)`
    DRIVER_MODULE_GPU=`(find /sys/ | grep drivers.*$IDBUS | cut -d "/" -f 6)`
    
    #Print GPU														#
    LINESTRING=`(cat file_lshw_class_display.tmp | head -3 | tail -1)`
    FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
    FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
    echo -e "GPU:\t\t\t$FORMATTED_STRING - [Driver:$DRIVER_MODULE_GPU]"    
	
	# Nvidia
	if command -v nvidia-smi >/dev/null; then
		echo -e "VRAM:\t\t\t$(nvidia-smi --query-gpu=memory.total --format=csv,noheader)"
	# AMD and Intel
	elif ls /sys/class/drm/card*/device/mem_info_vram_total >/dev/null 2>&1; then
		for file in /sys/class/drm/card*/device/mem_info_vram_total; do
			[ -f "$file" ] || continue
			VRAM_AMD_GPU=$(awk '{printf "%.2f GB\n", $1/1024/1024/1024}' "$file")
			echo -e "VRAM:\t\t\t$VRAM_AMD_GPU"
		done
	# Unsupported cards
	else
		echo -e "VRAM:\t\t\tUnavailable via standard interfaces"
	fi
	
	echo ""
}

function printNIC()
{
	echo ""
	echo "Network Interfaces"
	echo "---------------------------------------------------------------------------------"
	#Ethernet controller
	lspci | grep 'Ethernet controller' >> ethernet_nic.tmp
	
	input="./ethernet_nic.tmp"
	while IFS= read -r line
	do
		LINESTRING=$line				
		SEARCH_STRING="Ethernet controller: "			
		# Busid for current network controller	
		IDBUS=`(echo "$line" | cut -d " " -f 1)`
		DRIVER_MODULE_NIC=`(find /sys/ | grep drivers.*$IDBUS | cut -d "/" -f 6)`
		# The name of the enthernet controller
		FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
		echo -e "Ethernet:\t\t$FORMATTED_STRING - [Driver: $DRIVER_MODULE_NIC]"
	done < "$input"	
	rm ethernet_nic.tmp
	
	#Wifi
	lspci | grep 'Network controller' >> wifi_nic.tmp
	input="./wifi_nic.tmp"
	while IFS= read -r line
	do
		LINESTRING=$line
		SEARCH_STRING="Network controller:"
		
		# Busid for current network controller	
		IDBUS=`(echo "$line" | cut -d " " -f 1)`
		DRIVER_MODULE_WIFI=`(find /sys/ | grep drivers.*$IDBUS | cut -d "/" -f 6)`
		
		FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
		FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
		echo -e "Wifi:\t\t\t$FORMATTED_STRING - [Driver: $DRIVER_MODULE_WIFI]"
	done < "$input"
	#Remove temp file
	rm wifi_nic.tmp
	echo ""
}

function printAudio()
{
	echo ""
	echo "Audio"
	echo "---------------------------------------------------------------------------------"
	lspci | grep 'Audio device' >> audio.tmp
	input="./audio.tmp"
	while IFS= read -r line
	do
		LINESTRING=$line
		SEARCH_STRING="Audio device:"
		
		# Busid for current audio device	
		IDBUS=`(echo "$line" | cut -d " " -f 1)`
		DRIVER_MODULE_AUDIO=`(find /sys/ | grep drivers.*$IDBUS | cut -d "/" -f 6)`
		
		FORMATTED_STRING=${LINESTRING#*$SEARCH_STRING}
		FORMATTED_STRING="$(echo -e "${FORMATTED_STRING}" | sed -e 's/^[[:space:]]*//')"
		echo -e "Audio:\t\t\t$FORMATTED_STRING - [Driver: $DRIVER_MODULE_AUDIO]"
		
	done < "$input"
	
	rm audio.tmp
	echo ""
}

function printHDD()
{
	echo ""
	echo "Storage"
	echo "---------------------------------------------------------------------------------"

	lsblk -dn -o NAME,TYPE | awk '$2=="disk" {print $1}' >> storage_discs.tmp
	
	
	input="./storage_discs.tmp"
	COUNTER=0;
	while IFS= read -r line
	do
		#Returns "sata" or "nvme"
		STORAGE_INTERFACE=$(lsblk -dn -o TRAN "/dev/$line")
		
		COUNTER_SATA=0;
		#Sata based Interfaces - SSD and HDD
		if [ "$STORAGE_INTERFACE" = "sata" ]; then
			
			COUNTER_SATA=$(( COUNTER_SATA + 1 ))
			# Get Model Number, replace multiple spaces with one and extract Name of model
			MODELNUMBER_SATA=`(hdparm -I /dev/$line | grep "Model Number"  | awk '{$2=$2};1' | cut -d ":" -f2 | awk '{$1=$1};1')`
			# Append /dev/
			CAPACITY_SATA=`(hdparm -I /dev/$line | grep "device size with M = 1000" | cut -d "(" -f2 | cut -d ")" -f1)`		
			echo -e "Storage Sata $COUNTER_SATA:\t\t$MODELNUMBER_SATA - [$CAPACITY_SATA]"

		# NVME based interfaces
		COUNTER_NVME=0;
		elif [ "$STORAGE_INTERFACE" = "nvme" ]; then
			#echo "NVMe device"
			COUNTER_NVME=$(( COUNTER_NVME + 1 ))
			MODELNUMBER_NVME=$(lsblk -dn -o MODEL "/dev/$line")
			CAPACITY_NVME=$(lsblk -dn -o SIZE "/dev/$line")
			
			echo -e "Storage NVME $COUNTER_NVME:\t\t$MODELNUMBER_NVME - [$CAPACITY_NVME]"
		else
			echo "Undefined storage interface"
		fi
		
	done < "$input"
	
	rm storage_discs.tmp
	
	echo ""
}

function printInputDevices()
{
	echo ""
	echo "Misc"
	echo "---------------------------------------------------------------------------------"

	cat file_lshw_short.tmp | lshw -short | grep -Ei "mouse|keyboard|touchpad|pointer" | awk '{$1=""; $2=""; print substr($0,3)}' >> all_input_devices.tmp
	input="./all_input_devices.tmp"
	while IFS= read -r one_input_device
	do
		echo -e "Input Device:\t\t$one_input_device"
	done < "$input"

	rm all_input_devices.tmp

	echo ""
}

# Reduce lshw calls - Creating temporary files - For efficiency
createFiles

printMotherBoardInfo
printCPUInfo
printRAMInfo
printGPUInfo
printHDD
printNIC
printAudio
printInputDevices

# Cleanup temporary files
deleteFiles
