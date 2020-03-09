#coding=utf-8
import os
import sys
import hashlib
import base64
from pkcs7 import PKCS7Encoder
from Crypto.Cipher import AES
from binascii import b2a_hex, a2b_hex
import random

class prpcrypt():
    def __init__(self, key, shift):
        self.key = key
        self.mode = AES.MODE_CBC
        self.shift = shift
    def encrypt(self, text):
        sha384 = hashlib.sha384()
        sha384.update(self.key.encode('utf-8'))
        res = sha384.digest()
        key = res[0:32];
        iv = res[32:48];
        cryptor = AES.new(key, self.mode,iv)

        #加密函数，如果text不是16的倍数【加密文本text必须为16的倍数！】，那就补足为16的倍数
        encoder = PKCS7Encoder()
        text = encoder.encode(text)
        text = cryptor.encrypt(text)

        #撒盐
        count = len(text)
        randomMax = ord('~') - ord('!')
        originBytes = bytearray(text)
        outBytes = range(2 * count);
        for i in range(0, count):
            outBytes[i * 2] = originBytes[i]
            outBytes[i * 2 + 1] = random.randint(0,9999)%randomMax + ord('!')

        #偏移
        for i in range(0, 2 * count):
            outBytes[i] = (outBytes[i] + self.shift)%256
            if outBytes[i] < 0 :
                outBytes[i] = outBytes[i] + 256
        return bytearray(outBytes)

def encryptFile(fileName,key = "hsyuntai.com",shift = 10):
    fileName = fileName.rstrip("\n")
    fileName = fileName.strip()
    if os.path.isdir(fileName):
        print "请打开文件而不是文件夹,Path:" + fileName
        return False
    if os.path.exists(fileName) == False:
        print "文件路径不存在,Path:" + fileName
        return False
    fileObject = open(fileName,'r')
    encryptStr = fileObject.read()
    fileObject.close()
    pc = prpcrypt(key,shift)
    # encryptStr = encryptStr.rstrip("\n")
    # encryptStr = encryptStr.rstrip(" ")
    e = pc.encrypt(encryptStr)
    if len(e) == 0:
        print "加密文件" + fileName + "失败"
        return False
    fileObject = open(fileName,'w')
    fileObject.write(e)
    fileObject.close()
    return True
