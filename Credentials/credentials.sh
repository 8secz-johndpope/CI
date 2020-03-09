#!/bin/sh

#--------------------------------------------
# 功能：提供操作keychain的方法
# 使用说明：
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## cd 到当前脚本所在路径
cd $( cd "$( dirname "$0"  )" && pwd  )

declare local currentShellPath=$(pwd)
cd $currentShellPath/..
declare local rootShellPath=$(pwd)
source $rootShellPath/Common/fastlane-credentials.sh
cd $currentShellPath

while getopts "u:p:" arg #选项后面的冒号表示该选项需要参数
do
    case $arg in
        u)
			username=$OPTARG
			;;
        p)
			password=$OPTARG
			;;
	      ?)
				#当有不认识的选项的时候arg为?
			echo "unkonw argument"
		;;
    esac
done

printf "%s\n" "~~~~~~~~credentials.sh start~~~~~~~~~~"
printf "%s\n" "入参 -u (username): $username"
printf "%s\n" "入参 -p (password): $password"

if [ -z "$username" ]
then
	printf "%s\n" "~~~~~~~~username未配置~~~~~~~~~"
  exit -1
fi

if [ -n "$password" ]
then
  func_fastlaneCredentiasAddToKeychain "$username" "$password"
else
  printf "%s\n" "~~~~~~~~password未配置，则从keychain中删除~~~~~~~~~"
  func_fastlaneCredentiasRemoveFromKeychain "$username"
fi

printf "%s\n" "~~~~~~~~credentials.sh end~~~~~~~~~~"
