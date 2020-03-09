#!/bin/sh

#--------------------------------------------
# 功能：提供操作plist方法
# 使用说明：
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## $1: Configration root dir
function func_plistGetConfigrationOfCertificateProfilePath() {
  if [ -d $1 ]
  then
    echo "$1/Configration/SystemConfig/certificateProfile.plist"
  fi
}

## $1: Configration root dir
function func_plistGetConfigrationOfExportOptionsPlistPath() {
  if [ -d $1 ]
  then
    echo "$1/Configration/SystemConfig/exportOptions.plist"
  fi
}

## $1:appleID,
function func_plistResetCertificateProfilePlist() {
	local appleID=$1
	local certificateProfilePlistPath=$(func_plistGetConfigrationOfCertificateProfilePath $(func_commonGetGlobalShellPath))
	if [ -f $certificateProfilePlistPath ]
	then
		if [ -n "$appleID" ]
		then
			/usr/libexec/PlistBuddy -c "Set :username $appleID" ${certificateProfilePlistPath}
		fi
    printf "%s\n" "~~~~~~~~打印相关苹果账号信息~~~~~~~~~"
    /usr/libexec/PlistBuddy -c "print" $certificateProfilePlistPath
	fi
}

## $1: zzz/yyy/certificateProfile.plist
function func_plistGetAppleIDWithCertCfgPath() {
  if [ -z "$1" -o ! -f "$1" ]
  then
    echo "$(/usr/libexec/PlistBuddy -c "print username" $(func_plistGetConfigrationOfCertificateProfilePath $(func_commonGetGlobalShellPath)))"
  else
    echo "$(/usr/libexec/PlistBuddy -c "print username" $1)"
  fi
}

## $1: Info.plist路径
function func_plistGetBundleIdentifierWithInfoPlistDir() {
	local infoPlistPath=$1/Info.plist
	if [ -f $infoPlistPath ]
	then
    echo "$(/usr/libexec/PlistBuddy -c "print CFBundleIdentifier" ${infoPlistPath})"
	fi
}

## $1: Info.plist路径
function func_plistGetAppNameWithInfoPlistDir() {
	local infoPlistPath=$1/Info.plist
	if [ -f $infoPlistPath ]
	then
    echo "$(/usr/libexec/PlistBuddy -c "print CFBundleDisplayName" ${infoPlistPath})"
	fi
}

## $1: Info.plist路径
function func_plistGetAppVersionWithInfoPlistDir() {
	local infoPlistPath=$1/Info.plist
	if [ -f $infoPlistPath ]
	then
    echo "$(/usr/libexec/PlistBuddy -c "print CFBundleShortVersionString" ${infoPlistPath})"
	fi
}

## $1: Info.plist路径
function func_plistGetAppBuildVersionWithInfoPlistDir() {
	local infoPlistPath=$1/Info.plist
	if [ -f $infoPlistPath ]
	then
    echo "$(/usr/libexec/PlistBuddy -c "print CFBundleVersion" ${infoPlistPath})"
	fi
}

## $1:teamID, $2:exportMethod, $3:exportPlistPath
function func_plistResetExportOptionsPlist() {
	local teamID=$1
	local exportMethod=$2
	local exportPlistPath=$(func_plistGetConfigrationOfExportOptionsPlistPath $(func_commonGetGlobalShellPath))
	if [ -f $exportPlistPath ]
	then
		if [ -n "$teamID" ]
		then
			/usr/libexec/PlistBuddy -c "Set :teamID $teamID" ${exportPlistPath}
		fi

		if [ -n "$exportMethod" ]
		then
			/usr/libexec/PlistBuddy -c "Set :method $exportMethod" ${exportPlistPath}
		fi

    /usr/libexec/PlistBuddy -c "Delete :provisioningProfiles" ${exportPlistPath}
    /usr/libexec/PlistBuddy -c "Add :provisioningProfiles dict" ${exportPlistPath}
    /usr/libexec/PlistBuddy -c "Add provisioningProfiles:$3 string $4" ${exportPlistPath}

    printf "%s\n" "~~~~~~~~~~~~~~~~~~~重置ExportOptionsPlist后的内容~~~~~~~~~~~~~~~~~~~"
    /usr/libexec/PlistBuddy -c "print" $exportPlistPath
	fi
}

## $1:Info.plist路径, $2:buildOption.plist path,
function func_plistResetInfoPlistWithInfoPlistDirAndBuidOptionPlistPath() {
	local infoPlistPath=$1/Info.plist
	local buildOptionPlistPath=$2
	if [ ! -f $infoPlistPath ]
	then
    printf "%s\n" "Error：无法读取info.plist文件或则路径错误！"
		exit -1
	else
		str="$(/usr/libexec/PlistBuddy -c "print NSCameraUsageDescription" ${infoPlistPath})"
		if [ -z "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :NSCameraUsageDescription 亲，打开相机可以吗？" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print NSLocationWhenInUseUsageDescription" ${infoPlistPath})"
		if [ -z "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :NSLocationWhenInUseUsageDescription 中国" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print NSMicrophoneUsageDescription" ${infoPlistPath})"
		if [ -z "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :NSMicrophoneUsageDescription 亲，打开麦克风可以吗" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print NSPhotoLibraryUsageDescription" ${infoPlistPath})"
		if [ -z "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :NSPhotoLibraryUsageDescription 亲，打开相册可以吗？" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print NSContactsUsageDescription" ${infoPlistPath})"
		if [ -z "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :NSContactsUsageDescription 亲，打开通讯录可以吗？" ${infoPlistPath}
		fi
	fi

	if [ -z "$buildOptionPlistPath" -o ! -f "$buildOptionPlistPath" ];
	then
    printf "%s\n" "Info：buildOptionPlist文件不存在！"
  else
		str="$(/usr/libexec/PlistBuddy -c "print appid" ${buildOptionPlistPath})"
		if [ -n "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :CFBundleIdentifier $str" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print displayName" ${buildOptionPlistPath})"
		if [ -n "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName $str" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print version" ${buildOptionPlistPath})"
		if [ -n "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString $str" ${infoPlistPath}
		fi

		str="$(/usr/libexec/PlistBuddy -c "print buildVersion" ${buildOptionPlistPath})"
		if [ -n "$str" ]
		then
			/usr/libexec/PlistBuddy -c "Set :CFBundleVersion $str" ${infoPlistPath}
		fi

		qq="$(/usr/libexec/PlistBuddy -c "print hsqq" ${buildOptionPlistPath})"
		wx="$(/usr/libexec/PlistBuddy -c "print hsweixin" ${buildOptionPlistPath})"
		wb="$(/usr/libexec/PlistBuddy -c "print com.weibo" ${buildOptionPlistPath})"
		alipay="$(/usr/libexec/PlistBuddy -c "print hsalipay" ${buildOptionPlistPath})"

		# 配置CFBundleURLTypes
		/usr/libexec/PlistBuddy -c "Delete :CFBundleURLTypes" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes array" $infoPlistPath

		index=0
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index dict" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLName string hsqq" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $qq" $infoPlistPath

		index=1
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index dict" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLName string com.weibo" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $wb" $infoPlistPath

		index=2
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index dict" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLName string hsweixin" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $wx" $infoPlistPath

		index=3
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index dict" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLName string hsalipay" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $infoPlistPath
		/usr/libexec/PlistBuddy -c "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $alipay" $infoPlistPath
	fi
  printf "%s\n" "~~~~~~~~~~~~~~~~~~~重置后的infoPlist内容~~~~~~~~~~~~~~~~~~~"
  /usr/libexec/PlistBuddy -c "print" $infoPlistPath
}
