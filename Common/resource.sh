#!/bin/sh

#--------------------------------------------
# 功能：提供操作资源文件的方法
# 使用说明：
# 作者：luohs
# E-mail:luohuasheng0225@gmail.com
#--------------------------------------------

## 找出资源文件并加密
function encrypt() {
  for file in `ls $1`
  do
    if [ -d $1"/"$file ]
    then
      encrypt $1"/"$file
    else
      local path=$1"/"$file
      local fullname=$(basename $path)
      local filename=${fullname%.*}
      local extension=${fullname##*.}
      if [ "$extension" = "json" ]
      then
        python encrypt.py $path "etransfar"
      continue
      fi

      if [ "$extension" = "pem" ]
      then
        python encrypt.py $path "etransfar"
      continue
      fi
    fi
  done
}

## 拷贝资源文件,入参$1：工程路径，$2：用于打包资源文件
function backup() {
  printf "%s\n" "~~~~~~~~~~~~~~~~~~~备份、加密资源文件~~~~~~~~~~~~~~~~~~~"
  local resourceDir=$1
  local backupDir=$2
  if [ ! -d $resourceDir ]
  then
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~资源文件夹不存在~~~~~~~~~~~~~~~~~~~"
    return -1
  fi

  if [ `ls $resourceDir|wc -w` -le 0 ]
  then
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~资源文件夹不存在~~~~~~~~~~~~~~~~~~~"
    return -1
  fi

  if [ ! -d $backupDir ]
  then
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~备份文件夹不存在~~~~~~~~~~~~~~~~~~~"
    return -1
  fi

  ## 拷贝一份作为备份
  printf "%s\n" "~~~~~~~~~~~~~~~~~~~正在备份......~~~~~~~~~~~~~~~~~~~"
  cp -rf $resourceDir/* $backupDir

  if [ `ls $backupDir|wc -w` -gt 0 ]
  then
    encrypt $backupDir
  else
    printf "%s\n" "~~~~~~~~~~~~~~~~~~~备份文件夹不存在~~~~~~~~~~~~~~~~~~~"
    return -1
  fi
  return 0
}

## 拷贝资源文件,入参$1：工程路径，$2：用于打包资源文件
function func_resourceshellBackup() {
  local xcodeprojPath=$1
  local resourcePath=$2
  local backupPath="$xcodeprojPath/PackageResouces_backup"
  if [ -d $backupPath ];
  	then
  	rm -rf $backupPath
  fi
  mkdir $backupPath

  if [ -z "$resourcePath" -o ! -d "$resourcePath" ]
  then
    resourcePath=$xcodeprojPath/PackageResouces
  fi

  echo $(backup $resourcePath $backupPath)
}

function func_resourceshellRemove() {
  local xcodeprojPath=$1
  local backupPath="$xcodeprojPath/PackageResouces_backup"
  if [ -d $backupPath ];
  	then
  	rm -rf $backupPath
  fi
}
