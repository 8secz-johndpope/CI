#!/bin/sh
#!/bin/bash --login

#--------------------------------------------
# 功能：使用xcodebuild将.xcarchive打包成ipa格式
# 使用说明：	xcodebuild <input xcarchive path> <input export plist path> <out ipa path>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

function func_archiveExportToIPA() {
	local archivePath=$1
	local ipaOutputDir=$2
	local exportPlistPath=$3

	if [ -z "$archivePath" ]
	then
		printf "%s\n" "~~~~~~~~~~~archivePath未知~~~~~~~~~~~~"
		exit -1
	fi

	if [ -z "$exportPlistPath" ]
	then
		printf "%s\n" "~~~~~~~~~~~exportPlistPath未知~~~~~~~~~~~~"
		exit -1
	fi

	if [ -z "$ipaOutputDir" ]
	then
		printf "%s\n" "~~~~~~~~~~~ipaOutputDir未知~~~~~~~~~~~~"
		exit -1
	fi

	printf "%s\n" "archivePath: $archivePath"
	printf "%s\n" "ipaOutputDir: $ipaOutputDir"
	printf "%s\n" "exportPlistPath: $exportPlistPath"

	xcodebuild \
	-exportArchive \
	-archivePath ${archivePath} \
	-exportPath ${ipaOutputDir} \
	-exportOptionsPlist ${exportPlistPath}
}

rvm use system

exportArchive_ipa $1 $2 $3
