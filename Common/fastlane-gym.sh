#!/bin/sh

#--------------------------------------------
# 功能：fastlane gym
# 使用说明：	gym
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## $1:xcodeprojName, $2:schemeName, $3:codesign, $4:teamid, $5:provisionProfileSpecifier, $6:buildConfigration, $7:exportOptionsPlistPath, $8:archiveOutput,
function func_fastlaneGymBuild() {
	printf "%s\n" "fastlane gym"
	#生成安装包名称
	local xcodeprojName=$1
	local schemeName=$2
	local codesign=$3
	local teamid=$4
	local provisionProfileSpecifier=$5
	local buildConfigration=$6
	local exportOptionsPlistPath=$7
	local archiveOutput=$8

	local archiveName=$(func_commonGetAppName)_V$(func_commonGetAppVersion)_build$(func_commonGetAppBuildVersion)_`date +%Y%m%d%H%M%S`_$(func_commonGetGlobalBuildConfiguration)
	local archivePath="$(func_commonGetTempPath)/${archiveName}.xcarchive"

	# xcrun xcodebuild -list -workspace ${project_name}.xcworkspace
	# 解决Couldn't find specified scheme 'xxxx'.报错，需要打开工程去 mark scheme 'xxxx' Shared
	#open ${xcodeprojName}.xcworkspace
	sleep 1

	local codesignEscapeString=$(func_commonEscapeString "$codesign")
	local bundleIdentifier=$(func_commonGetBundleIdentifierFromXcodeBuildSettings)

	printf "%s\n" "xcodeprojName: $xcodeprojName"
	printf "%s\n" "schemeName: $schemeName"
	printf "%s\n" "codesign: $codesign"
	printf "%s\n" "teamid: $teamid"
	printf "%s\n" "provisionProfileSpecifier: $provisionProfileSpecifier"
	printf "%s\n" "buildConfigration: $buildConfigration"
	printf "%s\n" "exportOptionsPlistPath: $exportOptionsPlistPath"
	printf "%s\n" "archiveOutput: $archiveOutput"
	printf "%s\n" "codesignEscapeString: $codesignEscapeString"
	printf "%s\n" "bundleIdentifier: $bundleIdentifier"

	# build
	# --xcargs "PROVISIONING_PROFILE='${provisionProfileSpecifier}' PROVISIONING_PROFILE_SPECIFIER='${provisionProfileSpecifier}' DEVELOPMENT_TEAM='${teamid}' CODE_SIGNING_IDENTITY='${codesign}' PRODUCT_BUNDLE_IDENTIFIER='$(func_commonGetBundleIdentifier)'" \
	fastlane gym \
	--workspace ${xcodeprojName}.xcworkspace \
	--scheme ${schemeName} \
	--clean \
	--configuration ${buildConfigration} \
	--xcargs "PROVISIONING_PROFILE='${provisionProfileSpecifier}' PROVISIONING_PROFILE_SPECIFIER='${provisionProfileSpecifier}' DEVELOPMENT_TEAM='${teamid}' PRODUCT_BUNDLE_IDENTIFIER='$(func_commonGetBundleIdentifierFromXcodeBuildSettings)'" \
	--archive_path ${archivePath} \
	--codesigning_identity "${codesign}" \
	--export_options ${exportOptionsPlistPath} \
	--output_directory ${archiveOutput} \
	--output_name "${archiveName}"
}
