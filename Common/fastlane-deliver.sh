#!/bin/sh

#--------------------------------------------
# 功能：上传ipa到iTunesconnect
# 使用说明：	upload <input appleID> <input teamid> <input ipaPath>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## upload to iTunesConnect $1:appleID, $2:teamid, $3:ipaPath
function func_fastlaneDeliverUpload() {
	printf "%s\n" "fastlane pilot"
	local appleID=$1
	local teamid=$2
	local ipaPath=$3

	printf "%s\n" "appleID: $appleID"
	printf "%s\n" "teamid: $teamid"
	printf "%s\n" "ipaPath: $ipaPath"

	if [ -z "$appleID" ]
	then
		printf "%s\n" "~~~~~~~appleID未知！~~~~~~~~~~~"
		exit -1
	fi

	if [ -z "$teamid" ]
	then
		printf "%s\n" "~~~~~~~teamid未知！~~~~~~~~~~~"
		exit -1
	fi

	if [ -z "$ipaPath" -o ! -f "$ipaPath" ]
	then
			printf "%s\n" "~~~~~~~ipaPath未知！~~~~~~~~~~~"
			exit -1
	fi

	fastlane deliver \
	--username "${appleID}" \
	-f \
	--force \
	--skip_screenshots \
	--skip_metadata \
	-b "${teamid}" \
	--ipa "${ipaPath}"
}
