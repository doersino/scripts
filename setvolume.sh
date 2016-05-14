function setvolume() {
	local USAGE
	USAGE="usage: setvolume NUMBER_FROM_0_AND_7"
	if [ -z "$1" ]; then
		echo -e "$USAGE"; return 1
	fi
	osascript -e "set volume $1"
}