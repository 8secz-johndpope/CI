#!/bin/sh

#--------------------------------------------
# 功能：使用xcodebuild编译
# 使用说明：build
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

function func_xcode_build() {

  echo "开始编译......"
  #生成安装包名称
  local var_timestamp=`date +%Y%m%d%H%M%S`
  local var_name=JOB_${global_var_app_display_name}_${var_timestamp}_V${global_var_app_version}
  local var_archiveName="$global_path_output_archive/${var_name}.xcarchive"
  global_var_ipa_name=$var_name
  local var_provision_profile_path=${global_path_output_project_name}/$global_var_provision_name

  # 将xcode的配置文件设置为手动
  sed -i '' 's/ProvisioningStyle = Automatic;/ProvisioningStyle = Manual;/g' "$global_path_project_path/${global_path_project_name}.xcodeproj/project.pbxproj"

  if [ ! -f $var_provision_profile_path ];
      then
      echo "$var_provision_profile_path文件不存在！"
      exit 1
  fi

  # 读取信息profile UUID
  local var_profileSpecifier=$(/usr/libexec/PlistBuddy -c 'Print UUID' /dev/stdin <<< $(security cms -D -i $var_provision_profile_path))
  local var_project_name=$global_path_project_name
  local var_build_configuration=$global_var_build_configuration
  local var_appID=$global_var_appID
  local var_teamID=$global_var_teamID
  local var_export_method=$global_var_export_method
  local var_signIdentity=$global_var_signIdentity
  local path_export_options_plist=$global_path_export_option_plist
  local path_output_ipa=$global_path_output_ipa
  local var_iphoneos_deployment_target="7.0"
  # xcrun xcodebuild -list -workspace ${project_name}.xcworkspace
  # 解决Couldn't find specified scheme 'xxxx'.报错，需要打开工程去 mark scheme 'xxxx' Shared
  sleep 1
  open ${var_project_name}.xcworkspace

  echo "var_provision_profile_path: $var_provision_profile_path"
  echo "var_profileSpecifier: $var_profileSpecifier"
  echo "var_project_name: $var_project_name"
  echo "var_build_configuration: $var_build_configuration"
  echo "var_appID: $var_appID"
  echo "var_teamID: $var_teamID"
  echo "var_export_method: $var_export_method"
  echo "var_signIdentity: $var_signIdentity"
  echo "path_export_options_plist: $path_export_options_plist"
  echo "path_output_ipa: $path_output_ipa"
  echo "var_iphoneos_deployment_target: $var_iphoneos_deployment_target"

  # build
  # gym \
  # --workspace ${var_project_name}.xcworkspace \
  # --scheme ${var_project_name} \
  # --clean \
  # --include_symbols true \
  # --configuration ${var_build_configuration} --xcargs "PROVISIONING_PROFILE=${var_profileSpecifier} PROVISIONING_PROFILE_SPECIFIER=${var_profileSpecifier} DEVELOPMENT_TEAM=${var_teamID} 'CODE_SIGNING_IDENTITY=${var_signIdentity}' PRODUCT_BUNDLE_IDENTIFIER=${var_appID}" \
  # --export_method ${var_export_method} \
  # --archive_path ${var_archiveName} \
  # --codesigning_identity "${var_signIdentity}" \
  # --export_options ${path_export_options_plist} \
  # --output_directory ${path_output_ipa} \
  # --output_name "${var_name}"

  #清除环境
  # xcodebuild -workspace ${var_project_name}.xcworkspace \
  #            -scheme ${var_project_name} \
  #            -configuration ${var_build_configuration} \
  #            clean

  #build和archive
  xcodebuild -workspace ${var_project_name}.xcworkspace \
             -scheme ${var_project_name} \
             -configuration ${var_build_configuration} \
             build \
             SYMROOT=$global_path_output_archive \
             CODE_SIGN_IDENTITY="$var_signIdentity" \
             PRODUCT_BUNDLE_IDENTIFIER="$var_appID" \
             IPHONEOS_DEPLOYMENT_TARGET="$var_iphoneos_deployment_target" \
             PROVISIONING_PROFILE_SPECIFIER="$var_profileSpecifier" \
             DEVELOPMENT_TEAM="${var_teamID}" \
             archive \
             -archivePath ${var_archiveName}

  # xcodebuild -target $var_project_name \
  #            -configuration $var_build_configuration \
  #            clean \
  #            build \
  #            SYMROOT=$global_path_output_archive \
  #            CODE_SIGN_IDENTITY="$var_signIdentity" \
  #            PRODUCT_BUNDLE_IDENTIFIER="$var_appID" \
  #            IPHONEOS_DEPLOYMENT_TARGET="$var_iphoneos_deployment_target" \
  #            PROVISIONING_PROFILE_SPECIFIER="$var_profileSpecifier" \
  #            DEVELOPMENT_TEAM="${var_teamID}" \

  if test $? -eq 0
  then
        echo "~~~~~~~~~~~~~~~~~~~编译成功~~~~~~~~~~~~~~~~~~~"
  else
        echo "~~~~~~~~~~~~~~~~~~~编译失败~~~~~~~~~~~~~~~~~~~"
        return 1
  fi

  appDir=$global_path_output_archive/$var_build_configuration-iphoneos  #app所在路径
  echo "开始打包$var_project_name.xcarchive成$var_project_name.ipa....."
  xcrun -sdk iphoneos PackageApplication -v $appDir/$var_project_name.app -o $global_path_output_archive/$var_project_name.ipa #1>>/dev/null #将app打包成ipa
  # cp -r $appDir/$projectName.app.dSYM $output/$ipaName.app.dSYM

  #设置系统的rvm环境
  #在生成ipa过程中如果出现以下错误，则需要调用rvm use system
  # Error Domain=IDEDistributionErrorDomain Code=14 "No applicable devices found." UserInfo=0x7ff1a72ddd80 {NSLocalizedDescription=No applicable devices found.}
  # ** EXPORT FAILED **
  #需要将rvm设置为系统默认的/usr/local/rvm/bin/rvm，本机由于安装了ruby-2.3.0，默认为/usr/local/rvm/gems/ruby-2.3.0
  #[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm"
  #rvm use system

  #生成ipa
  # xcodebuild -exportArchive \
  #            -archivePath ${var_archiveName} \
  #            -exportPath "${path_output_ipa}/${var_name}" \
  #            -exportOptionsPlist $path_export_options_plist
}
