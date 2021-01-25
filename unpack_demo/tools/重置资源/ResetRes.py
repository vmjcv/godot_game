#coding=utf-8
import sys
import os
import zipfile
import shutil
import re
import getopt
# step1 获得所有需要重命名并移动的png,ogg,wav
# step2 创建文件夹
# step3 复制文件并重新命名
# step4 删除原先文件

class ResetRes():
    def __init__(self,gamedir):
        self.m_gamedir=gamedir
        self.m_importdir=os.path.join(self.m_gamedir,".import")
        self.m_decompiledir=os.path.join(self.m_gamedir,"decompile")
        self.m_pngdir=os.path.join(self.m_decompiledir,"png")
        self.m_oggdir=os.path.join(self.m_decompiledir,"ogg")
        self.m_wavdir=os.path.join(self.m_decompiledir,"wav")
        
    def create_dir(self):
        if not os.path.exists(self.m_decompiledir):
            os.makedirs(self.m_decompiledir)
        if not os.path.exists(self.m_pngdir):
            os.makedirs(self.m_pngdir)
        if not os.path.exists(self.m_oggdir):
            os.makedirs(self.m_oggdir)
        if not os.path.exists(self.m_wavdir):
            os.makedirs(self.m_wavdir)


    def move_file(self,file_path):
        outputdir = self.m_decompiledir
        outputname = os.path.basename(file_path)
        name2 = os.path.splitext(outputname)[1]
        if name2.lower()==".png":
            outputdir = self.m_pngdir
            outputname = outputname[:outputname.find(".png")]+".png"
        elif name2.lower()==".ogg":
            outputdir = self.m_oggdir
            outputname = outputname[:outputname.find(".ogg")]+".ogg"
        elif name2.lower()==".wav":
            outputdir = self.m_wavdir
            outputname = outputname[:outputname.find(".wav")]+".wav"  
        print(file_path)
        print(os.path.join(outputdir,outputname))
        shutil.move(file_path,os.path.join(outputdir,outputname)) 


    def move_all_file(self,):
        filePathVector = getFilesAbsolutelyPath(self.m_importdir)
        for filename in filePathVector:
            name2 = os.path.splitext(filename)[1]
            print(name2)
            flag1 = name2.lower()==".png"
            flag2 = name2.lower()==".ogg"
            flag3 = name2.lower()==".wav"
            if flag1 or flag2 or flag3:
                self.move_file(filename)

    def run(self):
        self.create_dir()
        self.move_all_file()
    
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


def main():
    gamedir="../../game"
    ResetResObj=ResetRes(gamedir)
    ResetResObj.run()

if __name__ == '__main__':      
    main()
