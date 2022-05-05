#!/bin/bash
# This is an automated installation using root account. You can run this script
# although it is preferred to use setup.sh instead.

version="0.0.1"
module_name="snd-aloop"
remove_target="all"
modprobe_path="/etc/modprobe.d/${module_name}.conf"
modload_path="/etc/modules-load.d/${module_name}.conf"
devices=0
load_on_boot=1


################################################################################
# Library Codes                                                                #
################################################################################
_print_status() {
	__status_message=""
	case "$1" in
	warn|Warning|WARNING|warning)
		__status_message="[ WARNING ]"
		shift 1
		;;
	err|Error|ERROR|error)
		__status_message="[ ERROR ]"
		shift 1
		;;
	info|Info|INFO)
		__status_message="[ INFO ]"
		shift 1
		;;
	*)
		__status_message="[ INFO ]"
		;;
	esac

	1>&2 echo -e "$__status_message $@"
	unset __status_message
}

_check_user_permission() {
	if [ "$(id -u -n)" != "root" ]; then
		_print_status error "no root permission. Did you sudo or su?"
		exit 1
	fi

	if [ "$USER" == "root" ]; then
		_print_status error "\$USER is root. Export USER=non-root user."
		exit 1
	fi
}


################################################################################
# Execution                                                                    #
################################################################################
create_module_configurations() {
	echo "\
# snd-aloop.conf generated by SND-ALOOP CONFIGURATOR
snd-aloop" > "$modload_path"
	if [ $load_on_boot -eq 0 ]; then
		exit 0
	fi
}

create_modprobe_configurations() {
	_check_user_permission

	# validate input is a number
	if [[ ! ("$devices" =~ ^[0-9]+$) ]]; then
		_print_status error "invalid device value. Must be number."
		exit 1
	fi
	statement="\
# snd-aloop.conf generated by SND-ALOOP CONFIGURATOR"
	# process device list and index list
	if [ $devices -le 1 ] ; then
		dev_list=1
		index_list=0
		statement="$statement
snd-aloop
"
	else
		dev_list="$(printf '%0.s1,' $(seq 1 $devices))"
		dev_list="${dev_list%,}"
		index_list=$(seq -s , 0 $((devices - 1)))
		statement="$statement
options snd-aloop enable=$dev_list $index_list"
	fi

	# process pcm subdevices list
	# TODO: coming soon

	# create configuration file
	echo "$statement" > "$modprobe_path"

	# done.
	exit 0
}

remove_module_configurations() {
	_check_user_permission

	# remove files
	case "$remove_target" in
	modprobe)
		rm "$modprobe_path" &> /dev/null
		;;
	modload)
		rm "$modload_path" &> /dev/null
		;;
	all)
		rm "$modprobe_path" &> /dev/null
		rm "$modload_path" &> /dev/null
		;;
	*)
		_print_status error "unknown target to remove. Use --help."
		;;
	esac

	#done
	exit 0
}

print_version() {
	echo "$version"
	exit 0
}

print_help() {
	line="$(printf '%0.s─' $(seq 1 $(stty size | awk '{print $2}')))"
	echo -e "\
SND-ALOOP CONFIGURATOR
$line
The helper to configure SND-ALoop Audio Loopback Module. The index is programmed
to use 0,1,2,... sequences.

WARNING:
1. You need to be **su** or **sudo** to execute this program.

USAGE EXAMPLES:
1. $ $0 --devices 5
2. $ $0 --boot --devices 5
3. $ $0 --help
4. $ $0 --remove

ARGUMENTS
─────────
-b, --boot			to load module on boot.

-d, --devices [NUMBER]		generate number of loopback devices based on
				given [NUMBER] input.
				Example, to create 5 devices:
					1) $ program -d 5
					2) $ program --devices 5

-h, --help, help		to print this help guide.

-r, --remove [VALUE]		remove the configuration file from the system.
				It only takes 3 types of values:
					1. all - remove both modprobe and module
					         load.
					2. modprobe - remove only modprobe.
					3. modload - remove only module load.
				Default is all.
				Example:
					1. $ program --remove all
					2. $ program --remove modprobe
					3. $ program --remove modload

-v, --version			print program version."
	exit 0
}

_parse_arguments() {
if [ $# == 0 ]; then
	print_help
	exit 0
fi

while true; do
case "$1" in
-b|--boot)
	if [ $# -eq 1 ]; then
		load_on_boot=0
	fi
	create_module_configurations
	;;
-d|--devices)
	if [ "$2" != "" ] && [ "${2:1}" != "-" ]; then
		devices="$2"
		shift 1
	fi
	create_modprobe_configurations
	;;
-h|--help|help)
	print_help
	;;
-r|--remove)
	if [ "$2" != "" ] && [ "${2:1}" != "-" ]; then
		remove_target="$2"
		shift 1
	fi
	remove_module_configurations
	;;
-v|--version)
	print_version
	;;
*)
	if [ $load_on_boot -eq 0 ]; then
		exit 0
	fi
	_print_status error "unknown argument $1"
	exit 1
	;;
esac
shift 1
done
}

_parse_arguments $@