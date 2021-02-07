#coding=utf-8
import sys
import os
import zipfile
import shutil
import re
import getopt
from PIL import Image
import pngquant
#import platform
# 打完包本地的环境不能改变，打包更改代码逻辑与打包逻辑分开执行
# step1 拷贝文件夹
# step2 修改代码文件
# step3 删除文件夹

class Pack():
    def __init__(self,source_dir,outputfile):
        self.m_source_dir=source_dir
        self.m_outputfile=outputfile
        
        
    def copy_file(self,):
        shutil.rmtree(self.m_outputfile)
        shutil.copytree(self.m_source_dir, self.m_outputfile)
  
    def change_resfile(self,):
        #压缩图片深度为8位
        #if self.m_system=="Windows":   
        #   pass
        #elif self.m_system=="Darwin":
        #   pass
        filePathVector = getFilesAbsolutelyPath(self.m_outputfile)
        for filename in filePathVector:
            flag = filename.find(".png")
            if flag != -1:
                im = Image.open(filename)
                if im.mode != "P":
                    im = im.convert('P')
                    im.save(filename,optimize=True)
                    
    def change_resfile_byquant(self,):
        #压缩图片深度为8位
        #if self.m_system=="Windows":   
        #   pass
        #elif self.m_system=="Darwin":
        #   pass
        filePathVector = getFilesAbsolutelyPath(self.m_outputfile)
        for filename in filePathVector:
            flag = filename.find(".png")
            if flag != -1:
                pngquant.config("./pngquant.exe",min_quality = 80, max_quality = 100)
                pngquant.quant_image(filename)
                

    def delete_file(self):
        shutil.rmtree(self.m_temppack)
        
    def run(self):
        self.copy_file()
        self.change_resfile_byquant()
    
def getFilesAbsolutelyPath(ImageFilePath):
    currentfiles = os.listdir(ImageFilePath)
    filesVector = []
    for file_name in currentfiles:
        fullPath = os.path.join(ImageFilePath, file_name)
        if os.path.isdir(fullPath):
            newfiles = getFilesAbsolutelyPath(fullPath)
            filesVector.extend(newfiles)
        else:
            filesVector.append(fullPath)
    return filesVector


def replace( filePath, text, subs, flags=0 ):
    with open( filePath, "r+" ,encoding='UTF-8') as file:
        fileContents = file.read()
        textPattern = re.compile( re.escape( text ), flags )
        fileContents = textPattern.sub( subs, fileContents )
        file.seek( 0 )
        file.truncate()
        file.write( fileContents )
    
def main():
    inputfile="./未压缩文件夹"
    outputfile="./已压缩文件夹"
    packobj=Pack(inputfile,outputfile)
    packobj.run()

if __name__ == '__main__':      
    main()
