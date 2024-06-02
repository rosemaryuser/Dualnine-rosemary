#!/sbin/sh

set -x 

#defining path to directories
active_dir="/data/dualnine/active"
inactive_dir="/data/dualnine/inactive"
partitions_dir="/dev/block/by-name"
bootctl="/tmp/dualnine/bootctl"
current_slot=$(getprop ro.boot.slot_suffix)
#cleanup
cleanup(){
rm -rf /tmp/dualnine
rm -rf /data/dalvik-cache/*
}

#backup function 
backup(){
echo ""
echo ""
echo "Saving current slot."
#rename the source directory to destination directory
if [ -d "$inactive_dir" ]; then
   mv "$inactive_dir" "$active_dir"
fi
mkdir -p "$inactive_dir"/data   
#using dd bcoz don't trust pigz to copy 
#pigz -kc1 means keep original file compress to sdout with fastest compression which is -1
dd bs=1M if="$partitions_dir"/boot"$current_slot" | pigz -kc1 > "$inactive_dir"/boot.img.gz
dd bs=1M if="$partitions_dir"/dtbo"$current_slot" | pigz -kc1 > "$inactive_dir"/dtbo.img.gz
dd bs=1M if="$partitions_dir"/audio_dsp"$current_slot" | pigz -kc1 > "$inactive_dir"/audio_dsp.img.gz
dd bs=1M if="$partitions_dir"/cam_vpu1"$current_slot" | pigz -kc1 > "$inactive_dir"/cam_vpu1.img.gz
dd bs=1M if="$partitions_dir"/cam_vpu2"$current_slot" | pigz -kc1 > "$inactive_dir"/cam_vpu2.img.gz
dd bs=1M if="$partitions_dir"/cam_vpu3"$current_slot" | pigz -kc1 > "$inactive_dir"/cam_vpu3.img.gz
dd bs=1M if="$partitions_dir"/vbmeta"$current_slot" | pigz -kc1 > "$inactive_dir"/vbmeta.img.gz
dd bs=1M if="$partitions_dir"/vbmeta_system"$current_slot" | pigz -kc1 > "$inactive_dir"/vbmeta_system.img.gz
dd bs=1M if="$partitions_dir"/vbmeta_vendor"$current_slot"| pigz -kc1 > "$inactive_dir"/vbmeta_vendor.img.gz
dd bs=1M if="$partitions_dir"/gz"$current_slot" | pigz -kc1 > "$inactive_dir"/gz.img.gz
dd bs=1M if="$partitions_dir"/lk"$current_slot" | pigz -kc1 > "$inactive_dir"/lk.img.gz
dd bs=1M if="$partitions_dir"/md1img"$current_slot" | pigz -kc1 > "$inactive_dir"/md1img.img.gz
dd bs=1M if="$partitions_dir"/preloader_raw"$current_slot" | pigz -kc1 > "$inactive_dir"/preloader_raw.img.gz
dd bs=1M if="$partitions_dir"/preloader"$current_slot" | pigz -kc1 > "$inactive_dir"/preloader.img.gz
dd bs=1M if="$partitions_dir"/scp"$current_slot" | pigz -kc1 > "$inactive_dir"/scp.img.gz
dd bs=1M if="$partitions_dir"/spmfw"$current_slot" | pigz -kc1 > "$inactive_dir"/spmfw.img.gz
dd bs=1M if="$partitions_dir"/sspm"$current_slot" | pigz -kc1 > "$inactive_dir"/sspm.img.gz
dd bs=1M if="$partitions_dir"/tee"$current_slot" | pigz -kc1 > "$inactive_dir"/tee.img.gz
if [[ -e "$partitions_dir"/vendor_boot"$current_slot" ]]; then
    dd bs=1M if="$partitions_dir"/vendor_boot"$current_slot" | pigz -kc1 > "$inactive_dir"/vendor_boot.img.gz
fi
echo "Saving userdata for current slot"
#moving files inside source directory to destination directory
#so there is a problem coz you can't move /data/dualnine into /data/dualnine/inactive/data
#mv /data/* -t "$inactive_dir"/data
#solved
find /data/ -mindepth 1 -maxdepth 1 ! -name dualnine -exec mv -f {} "$inactive_dir"/data/ \; || exit 1
echo "1" > /data/dualnine/params/inactive;

if [ -f "$active_dir"/boot.img.gz ]; then
   restore=1
   current_slot=$("$bootctl" get-current-slot) || current_slot=$(bootctl get-current-slot)
fi
}

#restore function 
restore(){
pigz -dc "$active_dir"/boot.img.gz | dd bs=1M of="$partitions_dir"/boot"$active_slot"
pigz -dc "$active_dir"/boot.img.gz | dd bs=1M of="$partitions_dir"/boot"$active_slot"
pigz -dc "$active_dir"/dtbo.img.gz | dd bs=1M of="$partitions_dir"/dtbo"$active_slot"
pigz -dc "$active_dir"/audio_dsp.img.gz | dd bs=1M of="$partitions_dir"/audio_dsp"$active_slot"
pigz -dc "$active_dir"/cam_vpu1.img.gz | dd bs=1M of="$partitions_dir"/cam_vpu1"$active_slot"
pigz -dc "$active_dir"/cam_vpu2.img.gz | dd bs=1M of="$partitions_dir"/cam_vpu2"$active_slot"
pigz -dc "$active_dir"/cam_vpu3.img.gz | dd bs=1M of="$partitions_dir"/cam_vpu3"$active_slot"
pigz -dc "$active_dir"/vbmeta.img.gz | dd bs=1M of="$partitions_dir"/vbmeta"$active_slot"
pigz -dc "$active_dir"/vbmeta_system.img.gz | dd bs=1M of="$partitions_dir"/vbmeta_system"$active_slot"
pigz -dc "$active_dir"/vbmeta_vendor.img.gz | dd bs=1M of="$partitions_dir"/vbmeta_vendor"$active_slot"
pigz -dc "$active_dir"/gz.img.gz | dd bs=1M of="$partitions_dir"/gz"$active_slot"
pigz -dc "$active_dir"/lk.img.gz | dd bs=1M of="$partitions_dir"/lk"$active_slot"
pigz -dc "$active_dir"/md1img.img.gz | dd bs=1M of="$partitions_dir"/md1img"$active_slot"
pigz -dc  "$active_dir"/preloader_raw.img.gz | dd bs=1M of="$partitions_dir"/preloader_raw"$active_slot"
pigz -dc  "$active_dir"/preloader.img.gz | dd bs=1M of="$partitions_dir"/preloader"$active_slot"
pigz -dc "$active_dir"/scp.img.gz | dd bs=1M of="$partitions_dir"/scp"$active_slot"
pigz -dc "$active_dir"/spmfw.img.gz | dd bs=1M of="$partitions_dir"/spmfw"$active_slot"
pigz -dc "$active_dir"/sspm.img.gz | dd bs=1M of="$partitions_dir"/sspm"$active_slot"
pigz -dc "$active_dir"/tee.img.gz | dd bs=1M of="$partitions_dir"/tee"$active_slot"

if [ -e "$partitions_dir"/vendor_boot"$active_slot" ]; then
    pigz -dc "$active_dir"/vendor_boot.img.gz | dd bs=1M of="$partitions_dir"/vendor_boot"$active_slot"
fi
#moving files inside source directory to destination directory
mv -f "$active_dir"/data/* /data || exit 1
rm -rf "$active_dir"
}

#begining of script
if [ ! -f /data/dualnine/params/slot ]; then
    mkdir -p /data/dualnine/params
    touch /data/dualnine/params/slot
    echo "a" > /data/dualnine/params/slot
    echo ""
    setprop ro.dualnine.slot a
fi

backup

if [ "$restore" = 1 ]; then
    echo ""
    echo ""
    echo "Switching slots..."
    if [ "$current_slot" = "_b" ] || [ "$current_slot" = 1 ]; then 
	    $bootctl set-active-boot-slot 0 || bootctl set-active-boot-slot 0 || exit
		active_slot="_a"
	else 
	    $bootctl set-active-boot-slot 1 || bootctl set-active-boot-slot 1 || exit
		active_slot="_b"
	fi
    restore
	echo "Switched to active slot"
else
    echo "No inactive slot found. Skipping slot restore.."
    echo "You can flash the ROM you want to dualboot now."
fi

cleanup



