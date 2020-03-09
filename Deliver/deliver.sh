#!/bin/sh

#--------------------------------------------
# 功能：上传ipa
# 使用说明：
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## cd 到当前脚本所在路径
cd $( cd "$( dirname "$0"  )" && pwd  )

declare local currentShellPath=$(pwd)
cd $currentShellPath/..
declare local rootShellPath=$(pwd)
declare local buildShellPath="$rootShellPath/Build"
source $rootShellPath/Common/common.sh
source $rootShellPath/Common/fastlane-deliver.sh
source $rootShellPath/Common/fastlane-pilot.sh
source $rootShellPath/Common/plist.sh
cd $currentShellPath

while getopts "u:b:i:t:s:" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        u)
			username=$OPTARG
			;;
        b)
			appID=$OPTARG
			;;
        i)
			ipaPath=$OPTARG
				;;
				t)
			teamID=$OPTARG
				;;
				s)
			deliverStyle=$OPTARG
				;;
	      ?)
				#当有不认识的选项的时候arg为?
			echo "unkonw argument"
		;;
    esac
done

printf "%s\n" "~~~~~~~~deliver.sh start~~~~~~~~~~"
printf "%s\n" "入参 -u (username): $username"
printf "%s\n" "入参 -b (appID): $appID"
printf "%s\n" "入参 -i (ipaPath): $ipaPath"
printf "%s\n" "入参 -t (teamID): $teamID"
printf "%s\n" "入参 -s (deliverStyle): $deliverStyle"

if [ -z "$appID" ]
then
	printf "%s\n" "~~~~~~~~appID未配置~~~~~~~~~"
  exit -1
fi

if [ -z "$ipaPath" -o ! -f "$ipaPath" ]
then
	printf "%s\n" "~~~~~~~~ipaPath未配置~~~~~~~~~"
  exit -1
fi

## 设置root shell path
func_commonSetGlobalShellPath $rootShellPath

if [ -z "$username" ]
then
	username=$(func_commonGetAppleID)
fi

## upload ipa to testflight
func_fastlanePilotUpload "$username" "$appID" "$ipaPath"

printf "%s\n" "~~~~~~~~deliver.sh end~~~~~~~~~~"
## upload ipa to iTunesConnect
#func_fastlaneDeliverUpload "$username" "$(func_commonGetTeamID)" "$ipaPath"
