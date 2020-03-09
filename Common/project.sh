#!/bin/sh

#--------------------------------------------
# 功能：提供工程特有方法
# 使用说明：
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

# 在给定的文件夹内查找制定的文件路径,入参$1：制定的文件夹，$2：文件名称，$3：文件后缀名称
function func_findFileWithExtension() {
	list=`find $1 -maxdepth 1 -name "$2.$3"`
	for i in $list
  do
		echo $i
  done
}

## 在给定的文件夹内查找 *.xcodeproj文件,入参$1：制定的文件夹，$2：文件名称
function func_findProjectPathWithProjectDirAndProjectName() {
	var=$(func_findFileWithExtension $1 $2 xcodeproj)
	if [ -z "$var" ]
	then
		for file in `ls $1`
		do
			if [ -d $1/$file ]
			then
				func_findProjectPathWithProjectDirAndProjectName $1/$file $2
			fi
		done
	else
		# 将xcode的配置文件设置为手动
		sed -i '' 's/ProvisioningStyle = Automatic;/ProvisioningStyle = Manual;/g' "$var/project.pbxproj"
		echo $(dirname $var)
	fi
}

# 在给定的文件夹内查找 Info.plist文件,入参$1：制定的文件夹
function func_findInfoPlistPathWithProjectDir() {
	var=$(func_findFileWithExtension $1 Info plist)
	if [ -z "$var" ]
	then
		for file in `ls $1`
		do
			if [ -d $1/$file ]
			then
				func_findInfoPlistPathWithProjectDir $1/$file
			fi
		done
	else
		echo $(dirname $var)
	fi
}

function func_cocoapodsWithProjectPath() {
	printf "%s\n" "cocoapods install&update xcodeproj"
  local PROJECT_PATH=$1
  # 进入工程路径
  if [ ! "$(pwd)" = "${PROJECT_PATH}" ];
  then
    cd $PROJECT_PATH
  fi

  cp -f Podfile Podfile.bak
  sed -i '' "s/pod 'PackageResouces', *:path =>'PackageResouces'/pod 'PackageResouces', :path =>'PackageResouces_backup'/" $PROJECT_PATH/Podfile
  #sed -i '' "s/pod 'EHDSecurity', '0.1.0'/pod 'EHDSecurity', '0.2.0'/" $PROJECT_PATH/Podfile
  awk -F ':' '{print $0}' $PROJECT_PATH/Podfile
  # cocoapods
  # rm Podfile.lock
  # rm -rf *.xcworkspace
  # rm -rf Pods
  # pod update --verbose --no-repo-update
	pod install
  cp -f Podfile.bak Podfile
}
