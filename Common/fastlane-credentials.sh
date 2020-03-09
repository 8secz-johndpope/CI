#!/bin/sh

#--------------------------------------------
# 功能：操作keychain
# 使用说明：	在keychain中保存或删除账户密码
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## $1:username, $2:password
function func_fastlaneCredentiasAddToKeychain() {
  printf "%s\n" "fastlane credentias add"
  local username=$1
  local password=$2

  printf "%s\n" "username: $username"
  printf "%s\n" "password: $password"

  if [ -z "$username" ]
  then
    printf "%s\n" "~~~~~~~username未知！~~~~~~~~~~~"
    exit -1
  fi

  if [ -z "$password" ]
  then
    printf "%s\n" "~~~~~~~password未知！~~~~~~~~~~~"
    exit -1
  fi

  fastlane fastlane-credentials \
  add \
  --username "$username" \
  --password  "$password"
}

## $1:username
function func_fastlaneCredentiasRemoveFromKeychain() {
  printf "%s\n" "fastlane credentias remove"
  local username=$1

  printf "%s\n" "username: $username"

  if [ -z "$username" ]
  then
    printf "%s\n" "~~~~~~~username未知！~~~~~~~~~~~"
    exit -1
  fi

  fastlane fastlane-credentials \
  remove \
  --username "$username"
}
