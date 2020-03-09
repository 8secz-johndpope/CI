#!/bin/sh

#--------------------------------------------
# 功能：为使用了CocoaPods的工程打ipa包
# 使用说明：	build <cococapods project path> [<build configuration>]
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## cd 到当前脚本所在路径
cd $( cd "$( dirname "$0"  )" && pwd  )

declare local currentShellPath=$(pwd)
cd $currentShellPath/..
declare local rootShellPath=$(pwd)
source $rootShellPath/Common/common.sh
source $rootShellPath/Common/fastlane-sigh.sh
source $rootShellPath/Common/fastlane-deliver.sh
source $rootShellPath/Common/fastlane-gym.sh
source $rootShellPath/Common/fastlane-pilot.sh
source $rootShellPath/Common/resource.sh
source $rootShellPath/Common/plist.sh
source $rootShellPath/Common/project.sh
cd $currentShellPath

# source init.sh
# source infoPlist-config.sh
# source projectPath.sh

# TEMP=`getopt -o ab:c:: --long a-long,b-long:,c-long:: -n 'example.bash' -- "$@"`
# # if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi
# # Note the quotes around `$TEMP': they are essential!
# eval set -- "$TEMP"
# while true ; do
#         case "$1" in
#                 -a|--a-long) echo "Option a" ; shift ;;
#                 -b|--b-long) echo "Option b, argument \`$2'" ; shift 2 ;;
#                 -c|--c-long)
#                         # c has an optional argument. As we are in quoted mode,
#                         # an empty parameter will be generated if its optional
#                         # argument is not found.
#                         case "$2" in
#                                 "") echo "Option c, no argument"; shift 2 ;;
#                                 *)  echo "Option c, argument \`$2'" ; shift 2 ;;
#                         esac ;;
#                 --) shift ; break ;;
#                 *) echo "Internal error!" ; exit 1 ;;
#         esac
# done
# echo "Remaining arguments:"
# for arg do echo '--> '"\`$arg'" ; done

# exit

while getopts "a:b:c:d:e:f:g:u:" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        a)
			projectDir=$OPTARG
			;;
        b)
			schemeName=$OPTARG
			;;
        c)
			resourceDir=$OPTARG
			;;
		    d)
			buildOptionsPath=$OPTARG
			;;
		    e)
			outputDir=$OPTARG
			;;
        f)
      buildConfiguration=$OPTARG
      ;;
        g)
      exportMethod=$OPTARG
      ;;
        u)
      username=$OPTARG
      ;;
        ?)  #当有不认识的选项的时候arg为?
			echo "unkonw argument"
		  ;;
    esac
done

printf "%s\n" "~~~~~~~~build.sh start~~~~~~~~~~"
printf "%s\n" "入参 -a (projectDir): $projectDir"
printf "%s\n" "入参 -b (schemeName): $schemeName"
printf "%s\n" "入参 -c (resourceDir): $resourceDir"
printf "%s\n" "入参 -d (buildOptionsPath): $buildOptionsPath"
printf "%s\n" "入参 -e (outputDir): $outputDir"
printf "%s\n" "入参 -f (buildConfiguration): $buildConfiguration"
printf "%s\n" "入参 -g (exportMethod): $exportMethod"
printf "%s\n" "入参 -u (appleID): $username"

if [ -z "$projectDir" -o ! -d "$projectDir" ]
then
  exit -1
else
  func_commonSetGlobalProjectDir $projectDir
  func_commonSetGlobalShellPath $rootShellPath
fi

if [ -z "$schemeName" ]
then
  schemeName=$(func_commonGetDefaultSchemeName)
  if [ -z "$schemeName" ]
  then
    exit -1
  fi
fi

if [ -z "$outputDir" -o ! -d "$outputDir" ]
then
  outputDir="$(func_commonGetGlobalProjectDir)/output"
  if [ -d $outputDir ]
  then
    rm -rf $outputDir
  fi
  mkdir $outputDir
  printf "%s\n" "outputDir: $outputDir"
fi

if [ -n "$buildConfiguration" ]
then
  func_commonSetGlobalBuildConfiguration $buildConfiguration
fi

if [ -n "$exportMethod" ]
then
  func_commonSetGlobalExportMethod $exportMethod
fi

projectName=$(func_commonGetProjectNameWithXcodebuildListCommand)
if [ -z "$projectName" ]
then
  exit -1
fi

## unlock keychain db
security unlock-keychain -p "123456" $HOME/Library/Keychains/login.keychain

## 设置appleID
if [ -n "$username" ]
then
  func_plistResetCertificateProfilePlist "$username"
  printf "\t\n"
fi

## 根据输入查找真正的xcodeproj路径
func_commonFindProjectPath "$projectDir" "$projectName"
if test $? -ne 0
then
  printf "%s\n" "~~~~~~~~未查询到工程路径~~~~~~~~~"
  exit -1
else
  printf "%s\n" "设置工程路径：$(func_commonGetProjectPath)"
  printf "\t\n"
fi

## 根据输入查找真正的info.plist路径
printf "%s\n" "~~~~~~~~查找Info.plst路径~~~~~~~~~"
func_commonFindInfoPlistPath "$(func_commonGetProjectPath)/$projectName"
if test $? -ne 0
then
  printf "%s\n" "~~~~~~~~未查询到Info.plst路径~~~~~~~~~"
  exit -1
else
  printf "%s\n" "info.plist路径：$(func_commonGetInfoPlistPath)"
  printf "\t\n"
fi

## 根据项目不同重置Info.plist配置项
if [ -z "$buildOptionsPath" -o ! -d "$buildOptionsPath" ]
then
  printf "%s\n" ""
else
  printf "%s\n" "~~~~~~~~根据传入的buildOptionsPlist重置InfoPlist内容~~~~~~~~~"
  func_commonResetInfoPlistWithBuidOptionPlistPath "$buildOptionsPath"
  printf "\t\n"
fi

## 根据项目不同拷贝资源文件
if [ -z "$resourceDir" -o ! -d "$resourceDir" ]
then
  printf "%s\n" ""
else
  printf "%s\n" "~~~~~~~~根据传入的resourceDir备份资源文件~~~~~~~~~"
  func_commonBackupResource "$(func_commonGetProjectPath)" "$resourceDir"
  printf "\t\n"
  if test $? -ne 0
  then
    printf "%s\n" "~~~~~~~~资源备份失败~~~~~~~~~"
    exit -1
  fi
fi

## cocoapods install & update xcworkspace
printf "%s\n" "~~~~~~~~pod文件生成workspace~~~~~~~~~"
func_commonCocoapods
printf "\t\n"

## open xxx.xcworkspace
# open $(func_commonGetProjectPath)/${projectName}.xcworkspace

## 安装p12证书文件
printf "%s\n" "~~~~~~~~查找证书~~~~~~~~~"
func_commonImportCertFile $(func_commonGetCertFilePathWithAppID $(func_commonGetBundleIdentifierFromXcodeBuildSettings))
# func_commonImportCertFile $(func_commonGetCertFilePathWithAppID $(func_commonGetBundleIdentifier))
if test $? -ne 0
then
  printf "%s\n" "~~~~~~~~未找到正确的证书~~~~~~~~~"
  exit -1
else
  printf "%s\n" "~~~~~~~~找到正确的证书~~~~~~~~~"
  printf "\t\n"
fi

## 下载mobileprovision文件
printf "%s\n" "~~~~~~~~下载mobileprovision文件~~~~~~~~~"
func_fastlaneSighDownloadProvisionProfile $(func_commonGetAppleID) $(func_commonGetBundleIdentifierFromXcodeBuildSettings) "$outputDir"
# func_fastlaneSighDownloadProvisionProfile $(func_commonGetAppleID) $(func_commonGetBundleIdentifier) "$outputDir"
printf "\t\n"

## 生成Entitlements
printf "%s\n" "~~~~~~~~根据mobileprovision配置文件生成EntitlementsPlist文件~~~~~~~~~"
func_commonCreateEntitlementsPlist
printf "\t\n"

# APPID=`/usr/libexec/PlistBuddy -c "Print application-identifier" "$output_dir"/Entitlements.plist`
# APPID=`echo ${APPID#*.}`
# if [ "$APPID" == "${bundleIdentifier}" ]
# then
#   printf "%s\n" "~~~~~~~~APPID验证通过~~~~~~~~~"
# else
#   printf "%s\n" "~~~~~~~~APPID验证失败~~~~~~~~~"
#   exit -1
# fi

## 获取provision profile uuid
printf "%s\n" "~~~~~~~~获取TEAMID~~~~~~~~~"
TEAMID=$(func_commonGetTeamID)
if [ -z "$TEAMID" ]
then
  printf "%s\n" "~~~~~~~~获取TEAMID失败~~~~~~~~~"
  exit -1
else
  printf "~~~~~~~~正确获取TEAMID：%s\n" "$TEAMID"
  printf "\t\n"
fi

## 获取provision profile uuid
UUID=$(func_fastlaneSighGetProvisionProfileSpecifier)
if [ -z "$UUID" ]
then
  printf "%s\n" "~~~~~~~~获取UUID失败~~~~~~~~~"
  exit -1
else
  printf "%s\n" "UUID:$UUID"
fi

## 重置exportOptions.plist配置项
printf "%s\n" "~~~~~~~~重置ExportOptionsPlist~~~~~~~~~"
func_commonResetExportOptionsPlist "$TEAMID" "$(func_commonGetGlobalExportMethod)" $(func_commonGetBundleIdentifierFromXcodeBuildSettings) "$UUID"
printf "\t\n"

## 进入到工程路径，为build做准备
cd $(func_commonGetProjectPath)

## build xcodeproj
printf "%s\n" "~~~~~~~~开始编译~~~~~~~~~"
func_fastlaneGymBuild "$projectName" "$schemeName" "$CERTNAME" "$TEAMID" "$UUID" "$(func_commonGetGlobalBuildConfiguration)" "$(func_plistGetConfigrationOfExportOptionsPlistPath $(func_commonGetGlobalShellPath))" "$outputDir"

## remove backup resource
#func_commonRemoveResource

##上传
if [ $exportMethod = "app-store" -a $buildConfiguration = "Release" ] ; then
  func_fastlanePilotUpload $(func_commonGetAppleID) $(func_commonGetBundleIdentifierFromXcodeBuildSettings) $outputDir/*.ipa
else
  printf "%s\n" $exportMethod
fi

## remove backup resource
func_commonRemoveResource

printf "%s\n" "~~~~~~~~build.sh end~~~~~~~~~~"
