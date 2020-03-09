#!/bin/sh

## cd 到当前脚本所在路径
cd $( cd "$( dirname "$0"  )" && pwd  )

declare local currentShellPath=$(pwd)
cd $currentShellPath/..
declare local rootShellPath=$(pwd)
source $rootShellPath/Common/common.sh
source $rootShellPath/Common/fastlane-sigh.sh
source $rootShellPath/Common/resource.sh
source $rootShellPath/Common/plist.sh
cd $currentShellPath

declare local var_current_path=$(pwd)
# var_ci_path=$HOME/Desktop/工作/iOS/CI
cd $var_current_path/..
var_ci_path=$(pwd)
source $var_ci_path/Common/common.sh
source $var_ci_path/Common/fastlane-sigh.sh
source $var_ci_path/Build/infoPlist-config.sh
cd $var_current_path
# source $HOME/Desktop/工作/iOS/CI/common.sh
# source $HOME/Desktop/工作/iOS/CI/fastlane-sigh.sh

source define.sh
source ipapath.sh
source common.sh
source sign.sh


global_var_resources_path=$var_current_path/$global_var_resource
global_var_configration_path=$var_current_path/"Configration"

## 创建临时文件夹
func_mkdir_build $1
## 查找ipa文件 $1为ipa所在的文件夹
func_search_ipa_file $1
## 读取配置文件
if [ -n "$2" -a -d $2 ]
	then
	global_var_configration_path=$2
fi
if [ -n "$3" -a -d $3 ]
	then
	global_var_resources_path=$3
fi
echo "IPA文件目录：$1"
echo "配置文件目录：$global_var_configration_path"
echo "图片资源目录：$global_var_resources_path"
func_read_configfile $global_var_configration_path
## 下载配置文件
func_download_profile $global_var_provision_output_path

for i in "${global_var_ipa_path_array[@]}"
do
	declare local fullname=$(basename $i)
  	declare local filename=${fullname%.*}
	## 解压ipa
	func_unzip_ipa $i $global_var_temp_output_path
	## 查找可执行文件
	func_find_exec_file $global_var_temp_output_path/$global_var_payload
	## 删除签名文件
	func_delete_codeSignature_file $global_var_temp_output_path/$global_var_payload
	## 拷贝资源文件
	func_copy_resources_file $global_var_temp_output_path/$global_var_payload/$APP $global_var_resources_path
	## 重置Info.plist
	if [ "$global_var_export_method" != "enterprise" ]
		then
		func_reset_plist $global_var_temp_output_path/$global_var_payload/$APP/Info.plist
	fi
	## 签名
	if [ "$global_var_export_method" = "enterprise" ]
        then
        var_signIdentity=4C544AAF070005CED34D9070084ADE7A609F2D1F
    elif [ "$global_var_export_method" = "ad-hoc" ]
        then
        var_signIdentity=8223E6322305B0BFBF9C86C8CA56F6D93D67C281
    elif [ "$global_var_export_method" = "app-store" ]
    	then
    	var_signIdentity=8CB8E9A124CAE32C736AF3492F202FDB99FFCB8D
    else
        var_signIdentity=8223E6322305B0BFBF9C86C8CA56F6D93D67C281
    fi
	func_codesign $global_var_temp_output_path/$global_var_payload/$APP "$var_signIdentity" ##$global_var_signIdentity #"8223E6322305B0BFBF9C86C8CA56F6D93D67C281"
	## 验签
	func_verify $global_var_temp_output_path/$global_var_payload/$APP
	## 重新打包
	func_zip_ipa $global_var_temp_output_path $global_var_output_path $filename

	echo "移除临时文件夹"
	rm -rf $global_var_temp_output_path
	if [ -d $global_var_output_path/Payload ]
		then
		rm -rf $global_var_output_path/Payload
	fi

	if [ -d $global_var_output_path/Symbols ]
		then
		rm -rf $global_var_output_path/Symbols
	fi

	cd $var_current_path
done
