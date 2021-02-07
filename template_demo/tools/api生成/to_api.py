#coding=utf-8
import sys
import os
import shutil
import re
from enum import Enum
import collections
import yaml
import glob
# step1 加载代码文件,删除除注释以外的代码,保存类中的公共变量,公共信号,公共方法,继承对象中的暴露方法等
# step2 生成md文件
# step3 生成网址并打开

class Parse():
    def __init__(self,code_dir,api_dir,mk_path):
        self.m_code_dir=code_dir
        self.m_api_dir=api_dir
        self.m_mk_path=mk_path
        self.class_node=collections.OrderedDict()

    def get_all_class(self,):
        file_path=[]
                  
        exclude = set(['addons'])
        extensions = set(['.gd'])
        for root, dirs, files in os.walk(self.m_code_dir, topdown=True):
            dirs[:] = [d for d in dirs if d not in exclude]
            files = [file for file in files if os.path.splitext(file)[1] in extensions]
            for fname in files:
                gdpath=os.path.join(root, name)
                file_path.append(gdpath)
                  

        for path in file_path:
            self.class_node[path] = ClassNode(path,self.m_code_dir)


        for child_path,child_node in  self.class_node.items():
            if child_node.extends_class:
                # 如果有父类
                for parent_path,parent_node in self.class_node.items():
                    if parent_node.class_name == child_node.extends_class:
                        child_node.parent_node=parent_node
                        break


    def build_md(self,):
        for child_path,child_node in  self.class_node.items():
            md_string=""
            md_string+=child_node.path
            md_string = os.path.join(self.m_api_dir,md_string)
            temp_string = CreateMd(child_node).run()
            parant_path = os.path.dirname(md_string)
            if not os.path.exists(parant_path):
                os.makedirs(parant_path)
            md_string=os.path.splitext(md_string)[0]+".md"
            with open(md_string, 'w',encoding="utf-8") as f:
                f.write(temp_string)

    def change_page(self,):
        with open(self.m_mk_path,"r",encoding="utf-8") as file:
            #mk_str =  file.read()
            data = yaml.load(file,Loader=yaml.FullLoader)

        api_str="- API:\n"
        api_list=[]
        for child_path,child_node in  self.class_node.items():
            md_string=""
            md_string+=child_node.path
            md_string = os.path.join(self.m_api_dir,md_string)
            parant_path = os.path.dirname(md_string)
            md_string=os.path.splitext(md_string)[0]+".md"

            md_string=os.path.relpath(md_string,os.path.join(self.m_mk_path, "../docs"))
            temp_string="  - "+child_node.class_name.name+": "+md_string+"\n"
            api_str+=temp_string
            api_list.append({child_node.class_name.name:md_string})
        for i in range(len(data["pages"])):
            if  "API" in data["pages"][i].keys():
                data["pages"][i]["API"]=api_list
                break
        #mk_str=re.sub("- API:\n(?!\s)", api_str, mk_str)
        with open(self.m_mk_path, 'w',encoding="utf-8") as f:
            yaml.dump(data,f,allow_unicode=True)
            #f.write(mk_str)


    def run(self):
        self.get_all_class()
        self.build_md()
        self.change_page()



class CreateMd():
    def __init__(self,class_node):
        self.class_node = class_node
        self.base_url='https://github.com/vmjcv/godot_game/tree/main/template_demo/game'
        self.link_url=os.path.join(self.base_url,class_node.path)
        self.base_str=""

    def add_title(self,number,str):
        temp_str=""
        temp_str+="#"*number
        temp_str+=" "
        temp_str+=str
        temp_str+="\n\n"
        self.base_str+=temp_str

    def add_link(self,str):
        temp_str=""
        temp_str+='<span style="float:right;">[[source]]('+str+')</span>'
        temp_str+="\n\n"
        self.base_str+=temp_str

    def add_code(self,str):
        temp_str=""
        temp_str+="```python\n"
        temp_str+=str
        temp_str+="\n```"
        temp_str+="\n\n"
        self.base_str+=temp_str

    def add_str(self,str):
        temp_str=""
        temp_str+=str
        temp_str+="\n\n"
        self.base_str+=temp_str

    def add_arguments(self,arguments,arguments_info):
        temp_str=""
        temp_str+="**Argument**\n"
        for key,value in arguments.items():
            temp_str+="- **%s**:%s"%(key,value)
            temp_str+="  "+str(arguments_info[key])+"\n"
        self.base_str+=temp_str

    def add_li(self,str,strvalue,str_info):
        temp_str=""
        if strvalue and str_info:
            temp_str+="- **%s**:%s  %s"%(str,strvalue,str_info)+"\n"
        elif strvalue:
            temp_str+="- **%s**:%s"%(str,strvalue)+"\n"
        elif str_info:
            temp_str+="- **%s**  %s"%(str,str_info)+"\n"
        else:
            temp_str+="- **%s**"%(str)+"\n"
        self.base_str+=temp_str

    def add_li2(self,str,strvalue,str_info):
        temp_str=""
        if strvalue and str_info:
            temp_str+="-- **%s**:%s  %s"%(str,strvalue,str_info)+"\n"
        elif strvalue:
            temp_str+="-- **%s**:%s"%(str,strvalue)+"\n"
        elif str_info:
            temp_str+="-- **%s**  %s"%(str,str_info)+"\n"
        else:
            str+="-- **%s**"%(str)+"\n"
        self.base_str+=temp_str


    def add_return(self,return_info):
        temp_str=""
        temp_str+="**Return**\n"
        temp_str+="- %s\n"%(return_info)
        self.base_str+=temp_str

    def run(self):
        if self.class_node.class_name:
            self.add_link(self.link_url)
            self.add_title(1,self.class_node.class_name.name)

        if self.class_node.class_info:
            self.add_str(self.class_node.class_info.info)

        if self.class_node.is_tool:
            self.add_title(2,"is_tool")

        if self.class_node.extends_class:
            self.add_title(1,"parent")
            if self.class_node.parent_node:
                self.add_link(os.path.join(self.base_url,self.class_node.parent_node.path ))
            self.add_title(2,self.class_node.extends_class.name)

        if self.class_node.signal:
            self.add_title(1,"signal")
            for key,value in self.class_node.signal.items():
                self.add_li(value.name,None,value.info)

        if self.class_node.enum:
            self.add_title(1,"enum")
            for key,value in self.class_node.enum.items():
                self.add_li(value.name,None,value.info)
                for paramskey,paramsvalue in value.params.items():
                    self.add_li2(paramskey,paramsvalue,None)


        if self.class_node.const:
            self.add_title(1,"const")
            for key,value in self.class_node.const.items():
                self.add_li(value.name,value.value,value.info)

        if self.class_node.export:
            self.add_title(1,"export")
            for key,value in self.class_node.export.items():
                self.add_li(value.name,value.value,value.info)


        if self.class_node.var:
            self.add_title(1,"var")
            for key,value in self.class_node.var.items():
                self.add_li(value.name,value.value,value.info)

        if self.class_node.onready:
            self.add_title(1,"onready")
            for key,value in self.class_node.onready.items():
                self.add_li(value.name,value.value,value.info)

        if self.class_node.func:
            self.add_title(1,"func")
            for key,value in self.class_node.func.items():
                self.add_link(self.link_url+"#L%s"%(value.line))
                self.add_title(2,value.name)

                temp_str=value.name+"("
                for paramskey,paramsvalue in value.params.items():
                    temp_str+=paramskey
                    temp_str+="="
                    temp_str+=str(paramsvalue)
                    temp_str+=","
                temp_str=temp_str[:-1]
                temp_str+=")"
                self.add_code(temp_str)
                self.add_str(value.info)

                self.add_arguments(value.params,value.params_info)
                self.add_return(value.return_info)

        return self.base_str




def find_line(matchObj,base_str):
    matchObj = re.search(re.escape(matchObj.group(0)), base_str)
    pos = matchObj.start()
    pattern = re.compile(r'\n')
    result = pattern.findall(base_str,pos)
    return len(result)

class ClassNode():
    """
    path="."#相对于script的相对路径
    class_name=""#全局类名
    preload_path=""#当作文件加载时的类名
    extends_class=""#继承对象
    is_tool=False#是否可在编辑器中使用
    signal=collections.OrderedDict()#信号字典

    enum=collections.OrderedDict()#枚举值
    const=collections.OrderedDict()#常量值
    export=collections.OrderedDict()#导出到编辑器的对象变量
    var=collections.OrderedDict()#对象变量
    onready=collections.OrderedDict()#初始化完成后的对象变量
    func=collections.OrderedDict()#对象方法
    class_info=""#类注释
    parent_node=""#父类节点
    """


    def __init__(self,path,code_dir):

        self.path="."#相对于script的相对路径
        self.class_name=""#全局类名
        self.preload_path=""#当作文件加载时的类名
        self.extends_class=""#继承对象
        self.is_tool=False#是否可在编辑器中使用
        self.signal=collections.OrderedDict()#信号字典

        self.enum=collections.OrderedDict()#枚举值
        self.const=collections.OrderedDict()#常量值
        self.export=collections.OrderedDict()#导出到编辑器的对象变量
        self.var=collections.OrderedDict()#对象变量
        self.onready=collections.OrderedDict()#初始化完成后的对象变量
        self.func=collections.OrderedDict()#对象方法
        self.class_info=""#类注释
        self.parent_node=""#父类节点


        self.path  = os.path.relpath(path,code_dir)
        self.preload_path  = "res://"+os.path.relpath(path,os.path.join(code_dir, ".."))

        with open(path,encoding="utf-8") as file:
            script_str =  file.read()

        with open(path,encoding="utf-8") as file:
            script_base_str =  file.read()

        pattern = re.compile(r'^tool$',re.M)
        matchObj = re.search(pattern, script_str, flags=0)

        if matchObj:
            line = find_line(matchObj,script_base_str)
            self.is_tool = NodeInfo().create_is_tool(line)
            pattern = re.compile(r'^tool$\n',re.M)
            script_str=re.sub(pattern,"",script_str)

        else:
            self.is_tool = False

        pattern = re.compile(r'^extends[ ]+(\S*)\s*$',re.M)
        matchObj = re.search(pattern, script_str, flags=0)
        if matchObj:
            line = find_line(matchObj,script_base_str)
            self.extends_class = NodeInfo().create_extends_class(matchObj.group(1),line)
            pattern = re.compile(r'^extends[ ]+(\S*)\s*$\n',re.M)
            script_str=re.sub(pattern,"",script_str)
        else:
            self.extends_class = False


        pattern = re.compile(r'^class_name[ ]+(\S*)\s*?.*?$',re.M)
        matchObj = re.search(pattern, script_str, flags=0)
        if matchObj:
            line = find_line(matchObj,script_base_str)
            self.class_name = NodeInfo().create_class_name(matchObj.group(1),line)
            pattern = re.compile(r'^class_name[ ]+(\S*)\s*?.*?$\n',re.M)
            script_str=re.sub(pattern,"",script_str)

        else:
            self.class_name = False


        pattern = re.compile(r'^signal[ ]+([A-Za-z0-9]\w*).*#(.*)$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.signal[matchObj.group(1)] = NodeInfo().create_signal(matchObj.group(2),matchObj.group(1),line)
        pattern = re.compile(r'^signal.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)


        pattern = re.compile(r'^enum[ ]+([A-Za-z0-9]\w*)[^{.]*{(.*)}.*?(?:#(.*)){0,1}$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.enum[matchObj.group(1)] = {"info":matchObj.group(3)}
            self.enum[matchObj.group(1)]["params"] = collections.OrderedDict()
            init = 0
            pattern2 = re.compile(r'[ ]*(\w+)[ ]*(?:=[ ]*([0-9+-]*)[ ]*){0,1},{0,1}',re.M)
            it2 = re.finditer(pattern2, matchObj.group(2), flags=0)
            for enumObj in it2:
                if enumObj.group(2):
                    self.enum[matchObj.group(1)]["params"][enumObj.group(1)] = enumObj.group(2)
                    init = int(enumObj.group(2))+1
                else:
                    self.enum[matchObj.group(1)]["params"][enumObj.group(1)] = init
                    init=init+1


            self.enum[matchObj.group(1)] = NodeInfo().create_enum(matchObj.group(3),matchObj.group(1),self.enum[matchObj.group(1)]["params"],line)


        pattern = re.compile(r'^enum.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)


        pattern = re.compile(r'^export[ ]+var[ ]+([A-Za-z0-9]\w*)[^=\n]*={0,1}(.*?)(?:#(.*)){0,1}$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.export[matchObj.group(1)] = NodeInfo().create_export(matchObj.group(3),matchObj.group(1),matchObj.group(2),line)
        pattern = re.compile(r'^export.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)


        pattern = re.compile(r'^const[ ]+([A-Za-z0-9]\w*)[^=\n]*={0,1}(.*?)(?:#(.*)){0,1}$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.const[matchObj.group(1)] = NodeInfo().create_export(matchObj.group(3),matchObj.group(1),matchObj.group(2),line)
        pattern = re.compile(r'^const.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)


        pattern = re.compile(r'^var[ ]+([A-Za-z0-9]\w*)[^=\n]*={0,1}(.*?)(?:#(.*)){0,1}$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.var[matchObj.group(1)] = NodeInfo().create_var(matchObj.group(3),matchObj.group(1),matchObj.group(2),line)
        pattern = re.compile(r'^var.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)


        pattern = re.compile(r'^onready[ ]+var[ ]+([A-Za-z0-9]\w*)[^=\n]*={0,1}(.*?)(?:#(.*)){0,1}$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.onready[matchObj.group(1)] = NodeInfo().create_export(matchObj.group(3),matchObj.group(1),matchObj.group(2),line)
        pattern = re.compile(r'^onready.*$\n',re.M)
        script_str=re.sub(pattern,"",script_str)

        pattern = re.compile(r'^#(.*)$',re.M)
        it = re.finditer(pattern, script_str, flags=0)
        self.class_info=""
        first = True
        for matchObj in it:
            if first:
                line = find_line(matchObj,script_base_str)
                first = False
            self.class_info += matchObj.group(1)
            self.class_info +="\n"

        if  self.class_info=="":
            self.class_info=False
        else:
            self.class_info=NodeInfo().create_class_info(self.class_info,line)
        pattern = re.compile(r'^#(.*)$\n',re.M)
        script_str=re.sub(pattern,"",script_str)

        print(script_str)
        print(r'^func[ ]+([A-Za-z0-9]\w*)[^\(.]*\((.*)\).*:[ ]*$(.*)(?=(\n\w)|(\n\n))')
        pattern = re.compile(r'^func[ ]+([A-Za-z0-9]\w*)[^\(.]*\((.*)\).*:[ ]*$(.*)(?=(\n\w)|(\n\n))',re.M|re.S)
        it = re.finditer(pattern, script_str, flags=0)
        for matchObj in it:
            line = find_line(matchObj,script_base_str)
            self.func[matchObj.group(1)] = collections.OrderedDict()
            self.func[matchObj.group(1)]["params"] =collections.OrderedDict()
            self.func[matchObj.group(1)]["paramsinfo"] =collections.OrderedDict()
            init = 0
            pattern2 = re.compile(r'[ ]*(\w+)[ ]*(?:=[ ]*([0-9+-]*)[ ]*){0,1}(?:[^,]*)',re.M)
            it2 = re.finditer(pattern2, matchObj.group(2), flags=0)
            for paramObj in it2:
                if paramObj.group(2):
                    self.func[matchObj.group(1)]["params"][paramObj.group(1)] = paramObj.group(2)
                else:
                    self.func[matchObj.group(1)]["params"][paramObj.group(1)] = init

            strlist=[]
            strlist.append([r'^\s*#\s*@:(.*)$',"func"])
            for key,value in self.func[matchObj.group(1)]["params"].items():
                strlist.append(['^\s*#\s*@'+key+':(.*)$',key])
            strlist.append([r'^\s*#\s*@return:(.*)$',"return"])

            for value in strlist:
                pattern3 = re.compile(value[0],re.M)
                paramObj = True
                while paramObj:
                    paramObj = re.search(pattern3, matchObj.group(3), flags=0)
                    if paramObj and paramObj.group(1):
                        self.func[matchObj.group(1)]["paramsinfo"][value[1]]=paramObj.group(1)
                        break
                    else:
                        break
            self.func[matchObj.group(1)] = NodeInfo().create_func(self.func[matchObj.group(1)]["paramsinfo"]["func"],matchObj.group(1),self.func[matchObj.group(1)]["params"],self.func[matchObj.group(1)]["paramsinfo"],self.func[matchObj.group(1)]["paramsinfo"]["return"],line)



        pattern = re.compile(r'^func.*?\s*\n(?=\w)',re.M|re.S)
        script_str=re.sub(pattern,"",script_str)

        pattern = re.compile(r'func.*?\s*\n*$',re.S)
        script_str=re.sub(pattern,"",script_str)


class NodeInfoType(Enum):
    signal = 1
    enum = 2
    const = 3
    export = 4
    var = 5
    onready = 6
    func = 7
    class_info = 8
    is_tool=9
    class_name=10
    extends_class=11

class NodeInfo():

    def __init__(self):
        self.info = ""#备注
        self.name = ""#参数名字
        self.value = 0#参数默认值
        self.params = collections.OrderedDict()#参数字典,key-value
        self.params_info = collections.OrderedDict()#参数信息,key-info
        self.node_type=0#节点类型
        self.line=0#所处行数
        self.return_info=""#返回说明


    def create_signal(self,info,key,line):
        self.info=info
        self.name=key
        self.node_type=NodeInfoType.signal
        self.line = line
        return self

    def create_enum(self,info,keyname,params,line):
        self.info=info
        self.name=keyname
        for key,value in params.items():
            self.params[key]=value
        self.node_type=NodeInfoType.enum
        self.line = line
        return self

    def create_const(self,info,key,value,line):
        self.info=info
        self.name=key
        self.value=value
        self.node_type=NodeInfoType.const
        self.line = line
        return self

    def create_export(self,info,key,value,line):
        self.info=info
        self.name=key
        self.value=value
        self.node_type=NodeInfoType.export
        self.line = line
        return self

    def create_var(self,info,key,value,line):
        self.info=info
        self.name=key
        self.value=value
        self.node_type=NodeInfoType.var
        self.line = line
        return self

    def create_onready(self,info,key,value,line):
        self.info=info
        self.name=key
        self.value=value
        self.node_type=NodeInfoType.onready
        self.line = line
        return self

    def create_func(self,info,key,params,params_info,return_info,line):
        self.info=info
        self.name=key
        for key,value in params.items():
            self.params[key]=value
        for key,value in params_info.items():
            self.params_info[key]=value
        self.node_type=NodeInfoType.func
        self.line = line
        self.return_info=return_info
        return self

    def create_class_info(self,info,line):
        self.info=info
        self.node_type=NodeInfoType.class_info
        self.line = line
        return self

    def create_is_tool(self,line):
        self.node_type=NodeInfoType.is_tool
        self.line = line
        return self

    def create_class_name(self,class_name,line):
        self.name = class_name
        self.node_type=NodeInfoType.class_name
        self.line = line
        return self

    def create_extends_class(self,class_name,line):
        self.name = class_name
        self.node_type=NodeInfoType.extends_class
        self.line = line
        return self


def main():
    code_dir="../../game"
    api_dir="../../docs/api"
    mk_path = "../../mkdocs.yml"
    parseobj=Parse(code_dir,api_dir,mk_path)
    parseobj.run()


if __name__ == '__main__':
    main()
