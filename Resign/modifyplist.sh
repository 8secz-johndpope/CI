#!/bin/sh

function func_modify_plist() {
	echo "配置Info.plist......"
	echo $1, $2
	if [ "$1" = "" -o "$2" = "" ]
	    then  
	    echo "参数错误，请参照格式: sh 'shell文件名称'.sh 'buildOptions.plist文件绝对路径' 'Info.plist文件夹绝对路径'"
	    exit -1
	fi

	# buildOptions.plist文件
	if [ -f $1 ]
		then
		local build_config_path=$1
		appid="$($PlistBuddy "print appid" ${build_config_path})"
		displayName="$($PlistBuddy "print displayName" ${build_config_path})"
		version="$($PlistBuddy "print version" ${build_config_path})"
		buildVersion="$($PlistBuddy "print buildVersion" ${build_config_path})"
		qq_appid="$($PlistBuddy "print hsqq" ${build_config_path})"
		wx_appid="$($PlistBuddy "print hsweixin" ${build_config_path})"
		wb_appid="$($PlistBuddy "print com.weibo" ${build_config_path})"
		alipay_id="$($PlistBuddy "print hsalipay" ${build_config_path})"
	fi

	if [ -d $2 ]
		then
		local info_plist=$2
		$PlistBuddy "Set :CFBundleIdentifier $appid" ${info_plist}
		$PlistBuddy "Set :CFBundleDisplayName $displayName" ${info_plist}
		$PlistBuddy "Set :CFBundleShortVersionString $version" ${info_plist}
		$PlistBuddy "Set :CFBundleVersion $buildVersion" ${info_plist}

		# 配置CFBundleURLTypes
		$PlistBuddy "Delete :CFBundleURLTypes" $info_plist
		$PlistBuddy "Add :CFBundleURLTypes array" $info_plist

		index=0
		$PlistBuddy "Add CFBundleURLTypes:$index dict" $info_plist
		$PlistBuddy "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLName string hsqq" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $qq_appid" $info_plist

		index=1
		$PlistBuddy "Add CFBundleURLTypes:$index dict" $info_plist
		$PlistBuddy "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLName string com.weibo" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $wb_appid" $info_plist

		index=2
		$PlistBuddy "Add CFBundleURLTypes:$index dict" $info_plist
		$PlistBuddy "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLName string hsweixin" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $wx_appid" $info_plist

		index=3
		$PlistBuddy "Add CFBundleURLTypes:$index dict" $info_plist
		$PlistBuddy "Add :CFBundleURLTypes:$index:CFBundleTypeRole string Editor" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLName string hsalipay" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes array" $info_plist
		$PlistBuddy "Add CFBundleURLTypes:$index:CFBundleURLSchemes:0 string $alipay_id" $info_plist

		$PlistBuddy "print" $info_plist
	fi
}
