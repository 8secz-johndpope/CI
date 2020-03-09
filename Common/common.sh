#!/bin/sh

#--------------------------------------------
# 功能：common.sh
# 使用说明：	提供一些公共方法
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

#IFS=$'\n'

# source init.sh
# source plist.sh
# source project.sh

# 宏定义
# PlistBuddy="/usr/libexec/PlistBuddy -c"
##

#### 变量
## 全局变量
### export_method: app-store, ad-hoc, package, enterprise, development, and developer-id
## 全局路径变量
## 局部变量

#################################
#### 私有方法
##################################

## 去除字符串首尾双引号
function privatefunc_commonGetStringWithRemoveHeadAndTailDoubleQuotationMarks() {
	echo $1 | sed 's/^["]*//g' | sed 's/["]*$//g'
}

## 根据shell第三方库jq操作json字符串
function privatefunc_commonJsonValueWithJsonKey() {
	echo $1 | jq .$2
}

## 返回json格式的xcode project信息
function privatefunc_commonXCProjectInfoJsonString() {
	if [ -z "$xcprojectInfoJsonString" ]
	then
		local currentPath=$(pwd)
		# 进入工程路径
		cd $(func_commonGetGlobalProjectDir)
		# 输出工程设置信息-json格式
	  xcprojectInfoJsonString=$(xcodebuild -list -json)
		# 进入到原来的路径地址
		cd $currentPath
	fi
	echo $xcprojectInfoJsonString
}

## 获取target名称，默认取数组中第一个
function privatefunc_commonGetTargetNameWithXcodebuildListCommand() {
	local jsonString=$(privatefunc_commonXCProjectInfoJsonString)
	local targetName=$(privatefunc_commonJsonValueWithJsonKey "$jsonString" "project.targets[0]")
	local targetName=$(privatefunc_commonGetStringWithRemoveHeadAndTailDoubleQuotationMarks $targetName)
	echo $targetName
}

## 获取scheme名称，默认取数组中第一个
function privatefunc_commonGetSchemeNameWithXcodebuildListCommand() {
	local jsonString=$(privatefunc_commonXCProjectInfoJsonString)
	local schemesName=$(privatefunc_commonJsonValueWithJsonKey "$jsonString" "project.schemes[0]")
	local schemesName=$(privatefunc_commonGetStringWithRemoveHeadAndTailDoubleQuotationMarks $schemesName)
	echo $schemesName
}

## 根据target buildsetttings 获取对应的bundleIdentifier
function privatefunc_commonGetBundleIdentifierFromXcodeBuildSettingsWithTargetName() {
	local targetName=$1
	local currentPath=$(pwd)
	# 进入工程路径
	cd $(func_commonGetGlobalProjectDir)
	# 输出工程设置信息-json格式
	local projectName=$(func_commonGetProjectNameWithXcodebuildListCommand)
	local path="$(xcodebuild -project $projectName.xcodeproj -target $targetName -showBuildSettings | grep -E "PRODUCT_SETTINGS_PATH|PRODUCT_BUNDLE_IDENTIFIER")"
	# 进入到原来的路径地址
	cd $currentPath

	OLD_IFS="$IFS"
	IFS=$'\n'
	path_arr=($path)
	len=`expr ${#path_arr[@]} / 2`
	for (( i = 0; i < $len; i++ )); do
	 	bundle_id_index=`expr $i \* 2`
	 	substr="    PRODUCT_BUNDLE_IDENTIFIER = "
	 	str=${path_arr[$bundle_id_index]}
	 	bundle_id=${str#$substr}
	 done
	IFS="$OLD_IFS"
	echo $bundle_id
}

#################################
#### 公开方法
##################################

## 获取workspace name或则xcodeproject name
function func_commonGetProjectNameWithXcodebuildListCommand() {
	local jsonString=$(privatefunc_commonXCProjectInfoJsonString)
	local projectName=$(privatefunc_commonJsonValueWithJsonKey "$jsonString" "project.name")
	local projectName=$(privatefunc_commonGetStringWithRemoveHeadAndTailDoubleQuotationMarks $projectName)
	echo $projectName
}

## 获取默认scheme名称
function func_commonGetDefaultSchemeName() {
	local tempschemeName=$(privatefunc_commonGetSchemeNameWithXcodebuildListCommand)
	if [ -z "$tempschemeName" -o "$tempschemeName" == "" ]
	then
		local tempschemeName=$(privatefunc_commonGetTargetNameWithXcodebuildListCommand)
	fi
	echo $tempschemeName
}

function func_commonGetBundleIdentifierFromXcodeBuildSettings() {
	local targetName=$(privatefunc_commonGetTargetNameWithXcodebuildListCommand)
	local bundleIdentifier=$(privatefunc_commonGetBundleIdentifierFromXcodeBuildSettingsWithTargetName $targetName)
	echo $bundleIdentifier
}

#################################
#### setter&getter
##################################

## $1: 输入的工程路径
function func_commonSetGlobalProjectDir() {
  globalProjectDir=$1
	printf "%s\n" "工程路径：$globalProjectDir"
}

function func_commonGetGlobalProjectDir() {
  echo $globalProjectDir
}

## $1: 打包脚本路径
function func_commonSetGlobalShellPath() {
  globalShellPath="$1"
	printf "%s\n" "脚本路径：$globalShellPath"
}

## return global shell path
function func_commonGetGlobalShellPath() {
  echo $globalShellPath
}

## $1: archive configuration
function func_commonSetGlobalBuildConfiguration() {
  globalBuildConfiguration="$1"
}

## return global archive configuration
function func_commonGetGlobalBuildConfiguration() {
	if [ -z "$globalBuildConfiguration" -o "$globalBuildConfiguration" == "" ]
	then
		globalBuildConfiguration="Release"
	fi
	echo $globalBuildConfiguration
}

## $1: exportMethod
function func_commonSetGlobalExportMethod() {
  globalExportMethod="$1"
}

## return global exportMethod
function func_commonGetGlobalExportMethod() {
	if [ -z "$globalExportMethod" -o "$globalExportMethod" == "" ]
	then
		globalExportMethod="app-store"
	fi
	echo $globalExportMethod
}

## $1、$2: 对于类似这种字符串可通过key取值 {rv:0,flag:1,url:http://www.jinhill.com,msg:test}，结果：rv=0
function func_commonGetValueWithKey(){
  echo $1 | sed 's/.*'$2':\([^,}]*\).*/\1/'
}

## $1: 删除字符串中的空格和空行
function func_commonTrimString() {
	echo $1 | sed 's/[[:space:]]//g'
}

## $1: 特殊字符前插入转义字符
function func_commonEscapeString() {
	echo "$1" | sed -e 's#[]{}()&% '\''[]#\\&#g'
}

## return temp path
function func_commonGetTempPath() {
  local tempPath="$(func_commonGetGlobalShellPath)/temp"
  if [ -d $tempPath ];
  then
    rm -rf $tempPath
  fi
  mkdir $tempPath
  echo "$tempPath"
}

## $1: zzz/yyy/certificateProfile.plist
function func_commonGetAppleID() {
  echo $(func_plistGetAppleIDWithCertCfgPath "$(func_plistGetConfigrationOfCertificateProfilePath $(func_commonGetGlobalShellPath))")
}

## $1: Info.plist路径
function func_commonGetBundleIdentifier() {
  echo $(func_plistGetBundleIdentifierWithInfoPlistDir "$(func_commonGetInfoPlistPath)")
}

## $1: Info.plist路径
function func_commonGetAppName() {
  echo $(func_plistGetAppNameWithInfoPlistDir "$(func_commonGetInfoPlistPath)")
}

## $1: Info.plist路径
function func_commonGetAppVersion() {
  echo $(func_plistGetAppVersionWithInfoPlistDir "$(func_commonGetInfoPlistPath)")
}

## $1: Info.plist路径
function func_commonGetAppBuildVersion() {
  echo $(func_plistGetAppBuildVersionWithInfoPlistDir "$(func_commonGetInfoPlistPath)")
}

## return local provisioningProfile path
function func_commonGetLocalProvisioningProfilesWithAppID() {
	# printf "%s\n" "~~~~~~~~开始到本地查找mobileprovision配置文件~~~~~~~~~"
  if [ -n "$1" ]
  then
		local localProvisioningProfile="$(func_commonGetGlobalShellPath)/certs/ProvisioningProfiles/distribution/$1.mobileprovision"
		if [ $(func_commonGetGlobalExportMethod) = "development" ] ; then
			localProvisioningProfile="$(func_commonGetGlobalShellPath)/certs/ProvisioningProfiles/development/$1.mobileprovision"
		elif [ $(func_commonGetGlobalExportMethod) = "enterprise" ] ; then
			localProvisioningProfile="$(func_commonGetGlobalShellPath)/certs/ProvisioningProfiles/distribution/$1.mobileprovision"
		elif [ $(func_commonGetGlobalExportMethod) = "app-store" ] ; then
			localProvisioningProfile="$(func_commonGetGlobalShellPath)/certs/ProvisioningProfiles/distribution/$1.mobileprovision"
		elif [ $(func_commonGetGlobalExportMethod) = "ad-hoc" ] ; then
			localProvisioningProfile="$(func_commonGetGlobalShellPath)/certs/ProvisioningProfiles/adhoc/$1.mobileprovision"
		fi

		if [ -f ${localProvisioningProfile} ]
		then
			# printf "%s\n" "~~~~~~~~本地找到mobileprovision配置文件~~~~~~~~~"
			# printf "%s\n" "mobileprovision配置文件路径：$localProvisioningProfile"
			echo ${localProvisioningProfile}
		else
			printf "%s\n" "~~~~~~~~本地未找到mobileprovision配置文件~~~~~~~~~"
		fi
  fi
}

## return cert file path
function func_commonGetCertFilePathWithAppID() {
  if [ -n "$1" ]
  then
		local p12certFilePath="$(func_commonGetGlobalShellPath)/certs/distribution/$1.p12"
		if [ $(func_commonGetGlobalExportMethod) = "development" ] ; then
			p12certFilePath="$(func_commonGetGlobalShellPath)/certs/development/$1.p12"
		elif [ $(func_commonGetGlobalExportMethod) = "enterprise" ] ; then
			p12certFilePath="$(func_commonGetGlobalShellPath)/certs/enterprise/$1.p12"
		fi
		echo $p12certFilePath
##    echo "$(func_commonGetGlobalShellPath)/certs/$1.p12"
  fi
}

## $1: zzz/yyy/xxx.p12
## 由于通过echo作为返回值时，输出的是一堆乱七八糟的文字，所以采用全局变量CERTNAME作为该函数的返回值
function func_commonImportCertFile() {
  #证书路径
	local CERTPATH="$(func_commonGetGlobalShellPath)/certs/distribution.p12"

	# if [ $(func_commonGetGlobalExportMethod) == "development" ]
	# then
	# 	CERTPATH="$(func_commonGetGlobalShellPath)/certs/development.p12"
	# fi

	if [ $(func_commonGetGlobalExportMethod) = "development" ] ; then
		CERTPATH="$(func_commonGetGlobalShellPath)/certs/development.p12"
	elif [ $(func_commonGetGlobalExportMethod) = "enterprise" ] ; then
		CERTPATH="$(func_commonGetGlobalShellPath)/certs/enterprise.p12"
	fi

  if [ -f "$1" ]
  then
    CERTPATH=$1
  fi

  if [ ! -f $CERTPATH ]
  then
    return -1
  fi

  #生成随机数
  local KEYCHAIN=`head -200 /dev/urandom |cksum|cut -f1 -d" "`
  local KEYCHAIN="xcodebuild.keychain"

  #生成自定义钥匙串
  security delete-keychain $KEYCHAIN
  security create-keychain -p "" $KEYCHAIN
  #导入证书到钥匙串
  security import $CERTPATH -k $KEYCHAIN -P "Yuntai20150309" -T /usr/bin/codesign
  if test $? -eq 0
  then
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~证书导入成功~~~~~~~~~~~~~~~~~~~"
    CERTNAME=`security find-certificate -p $KEYCHAIN|openssl x509 -noout -subject -nameopt oneline,-esc_msb|awk -F"CN \= " '{print $2'}|awk -F", OU \=" '{print $1}'|sed s@\"@@g`
    printf "%s\n" "CERTNAME:$CERTNAME"
    return 0
  else
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~证书导入入失败~~~~~~~~~~~~~~~~~~~"
    security delete-keychain $KEYCHAIN
    return -1
  fi
}

## $1:teamID, $2:exportMethod
function func_commonResetExportOptionsPlist() {
	func_plistResetExportOptionsPlist "$1" "$2" "$3" "$4"
}

## $1:Info.plist路径, $2:buildOption.plist path,
function func_commonResetInfoPlistWithBuidOptionPlistPath() {
  func_plistResetInfoPlistWithInfoPlistDirAndBuidOptionPlistPath "$(func_commonGetInfoPlistPath)" "$1"
}

## $1:project_dir, $2:project_name, return true or false
function func_commonFindProjectPath() {
  projectPath=$(func_findProjectPathWithProjectDirAndProjectName "$1" "$2")
	if [ -z $projectPath ]
	then
    return -1
	fi
  return 0 #shell脚本中0表示true，其他表示false
}

## eturn xcodeproj path
function func_commonGetProjectPath() {
  echo $projectPath
}

## find the info.plist path, return true or false
function func_commonFindInfoPlistPath() {
  infoPlistPath=$(func_findInfoPlistPathWithProjectDir "$1")
	if [ -z $infoPlistPath ]
	then
    return -1
	fi
  return 0 #shell脚本中0表示true，其他表示false
}

## return info.plst Path
function func_commonGetInfoPlistPath() {
  echo $infoPlistPath
}

## cocoapods xcodeproj
function func_commonCocoapods() {
  func_cocoapodsWithProjectPath $(func_commonGetProjectPath)
}

## 拷贝资源文件,入参$1：工程路径，$2：用于打包资源文件
function func_commonBackupResource() {
  func_resourceshellBackup $1 $2
}

## 拷贝资源文件,入参$1：工程路径
function func_commonRemoveResource() {
  func_resourceshellRemove $(func_commonGetProjectPath)
}

function func_commonCreateEntitlementsPlist() {
	security cms -D -i "$(func_fastlaneSighProvisionProfilePath)"
	/usr/libexec/PlistBuddy -x -c  "Print Entitlements" /dev/stdin <<< $(security cms -D -i "$(func_fastlaneSighProvisionProfilePath)") >"$outputDir"/Entitlements.plist
	if [ -f "$outputDir"/Entitlements.plist ]
	then
    entitlementsPlistPath="$outputDir/Entitlements.plist"
    cat $entitlementsPlistPath
	fi
}

function func_commonGetEntitlementsPlistPath() {
  echo $entitlementsPlistPath
}

function func_commonGetAppID() {
  local APPID=`/usr/libexec/PlistBuddy -c "Print application-identifier" $(func_commonGetEntitlementsPlistPath)`
  APPID=`echo ${APPID#*.}`
  if [ -n "$APPID" ]
  then
    echo $APPID
  else
    printf "%s\n" "~~~~~~未提取到APPID~~~~~~~~~"
  fi
}

function func_commonGetTeamID() {
  local TEAMID=`/usr/libexec/PlistBuddy -c "Print com.apple.developer.team-identifier" $(func_commonGetEntitlementsPlistPath)`
  if [ -n "$TEAMID" ]
  then
    echo $TEAMID
  else
    printf "%s\n" "~~~~~~未提取到TeamID~~~~~~~~~"
  fi
}
