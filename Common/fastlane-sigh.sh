#!/bin/sh

#--------------------------------------------
# 功能：download mobileprovision file
# 使用说明：	download <input appleID> <input appID> <input mobileprovision file name> <input mobileprovision file path>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

function func_fastlaneSighDownloadProvisionProfile() {
	local appleID="$1"
	local appID="$2"
	local provisionProfileOutput="$3"
	local provisionProfileName=$(func_commonGetGlobalExportMethod).mobileprovision
	printf "%s\n" "appleID: $appleID"
	printf "%s\n" "appID: $appID"
	printf "%s\n" "provisionProfileOutput: $provisionProfileOutput"
	printf "%s\n" "provisionProfileName: $provisionProfileName"

	fastlane sigh \
	$(func_fastlaneSighGetProfilesType) \
	--force false \
	--skip_install false \
	--skip_certificate_verification \
	--username "${appleID}" \
	--app_identifier "${appID}" \
	--filename "${provisionProfileName}" \
	--output_path "${provisionProfileOutput}"

	if [ -f ${provisionProfileOutput}/${provisionProfileName} ]
	then
		printf "%s\n" "~~~~~~~~mobileprovision配置文件下载成功~~~~~~~~~"
		provisionProfilePath="${provisionProfileOutput}/${provisionProfileName}"
		printf "%s\n" "mobileprovision配置文件路径：$provisionProfilePath"
	else
		printf "%s\n" "~~~~~~~~mobileprovision配置文件下载失败~~~~~~~~~"
		provisionProfilePath="$(func_commonGetLocalProvisioningProfilesWithAppID $(func_commonGetBundleIdentifierFromXcodeBuildSettings))"
	fi
}

function func_fastlaneSighProvisionProfilePath() {
	echo $provisionProfilePath
}

function func_fastlaneSighGetProvisionProfileSpecifier() {
	local profilePath=$(func_fastlaneSighProvisionProfilePath)
	if [ -n "$profilePath" -a -f "$profilePath" ]
	then
		echo $(/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< $(security cms -D -i $profilePath))
	fi
}

function func_fastlaneSighGetProfilesType() {
	local exportMethod=$(func_commonGetGlobalExportMethod)
	if [ "$exportMethod" = "app-store" -o "$exportMethod" = "enterprise" ];
  then
    echo ""
  elif [ "$exportMethod" = "ad-hoc" ];
  then
    echo "--adhoc"
  else
    echo "--development"
  fi
}
