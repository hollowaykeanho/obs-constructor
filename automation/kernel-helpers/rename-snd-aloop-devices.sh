#!/bin/bash
# variables
global_name="SND ALoop Loopback"

# parse devices
old_IFS="$IFS" && IFS=$'\n'
sinks=($(pacmd list-sinks | grep "name:" | grep "snd_aloop"))
sources=($(pacmd list-sources | grep "name:" | grep "snd_aloop"))
IFS="$old_IFS" && unset old_IFS

# load audio device manager
manager=""
if [ "$(pactl list short modules | grep device-manager)" == "" ]; then
	manager="$(pactl load-module module-device-manager)"
fi

# sink changes
i=0
for device in "${sinks[@]}"; do
	device="${device#*<}"
	device="${device%>*}"

	name="$global_name $i"
	pacmd "update-sink-proplist $device device.description='$name'"
	((i=i+1))
done

# source changes
i=0
for device in "${sources[@]}"; do
	device="${device#*<}"
	device="${device%>*}"

	# process name
	name="$global_name $i"
	skip_increment=false
	if [[ "$device" == *monitor* ]]; then
		if [ "${#sources[@]}" -eq 2 ]; then
			name="Alsa Input Monitor"
		else
			name="$name Monitor"
		fi
		skip_increment=true
	fi

	# update
	pacmd "update-source-proplist $device device.description='$name'"

	# end
	if [ "$skip_increment" != "true" ]; then
		((i=i+1))
	fi
done

# unload device manager
if [ "$manager" != "" ]; then
	pactl unload-module "$manager"
fi
