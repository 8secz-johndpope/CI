#coding=utf-8
import shutil
import os
import encryptServer
import setting
import sys

def recoverFile(targetFilePath):
    targetTempFilePath = targetFilePath + setting.main_source_fileName_temp
    if os.path.isdir(targetTempFilePath) == False:
        print "临时文件夹不存在" + targetTempFilePath
        return False

    if os.path.isdir(targetFilePath):
        os.system("rm -fr " + targetFilePath)
        print "还原临时文件夹" + targetTempFilePath
        os.rename(targetTempFilePath,targetFilePath)
    return True

def copyfile(sourceFilePath,targetFilePath):
    targetTempFilePath = targetFilePath + setting.main_source_fileName_temp
    if os.path.isdir(sourceFilePath) == False:
        print "文件夹不存在" + sourceFilePath
        return False
    count = 0
    for parent,dirnames,filenames in os.walk(sourceFilePath):
        fileLength = len(filenames)
        if fileLength != 0:
            count = count + fileLength
        if count == 0:
            print "文件夹内文件为空"
            return False
    if os.path.isdir(targetFilePath):
        if os.path.isdir(targetTempFilePath):
            os.system("rm -fr " + targetTempFilePath)
        print "创建临时文件夹" + targetTempFilePath
        os.rename(targetFilePath,targetTempFilePath)
    shutil.copytree(sourceFilePath,targetFilePath)
    return True
