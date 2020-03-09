#!/bin/sh

#--------------------------------------------
# 功能：upload to testflight
# 使用说明：	<input appleID> <input bundleIdentifier> <input ipaPath>
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## upload to testflight $1:appleID, $2:bundleIdentifier, $3:ipaPath
function func_fastlanePilotUpload() {
  printf "%s\n" "fastlane pilot"
  local appleID=$1
	local bundleIdentifier=$2
	local ipaPath=$3

  printf "%s\n" "appleID: $appleID"
  printf "%s\n" "bundleIdentifier: $bundleIdentifier"
  printf "%s\n" "ipaPath: $ipaPath"

  if [ -z "$appleID" ]
  then
    printf "%s\n" "~~~~~~~appleID未知！~~~~~~~~~~~"
    exit -1
  fi

  if [ -z "$bundleIdentifier" ]
  then
    printf "%s\n" "~~~~~~~bundleIdentifier未知！~~~~~~~~~~~"
    exit -1
  fi

  if [ -z "$ipaPath" -o ! -f "$ipaPath" ]
  then
      printf "%s\n" "~~~~~~~ipaPath未知！~~~~~~~~~~~"
      exit -1
  fi

  fastlane pilot \
  upload \
  --username "${appleID}" \
  --app_identifier "${bundleIdentifier}" \
  --changelog "Beta版本测试。" \
  --beta_app_description "构建版本为Beta版本供测试人员进行测试。" \
  --beta_app_feedback_email "18330@etransfar.com" \
  --ipa "${ipaPath}" \
  --skip_waiting_for_build_processing true
}
