#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     25/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import tkinter as tk
import tkinter.ttk as ttk
import operator

class rolefabuPage():
    def __init__(self,work):
        work.work=tk.Frame(work.tk)
        work.work.pack(pady=40,expand=True,fill=tk.BOTH)
        self.work=work.work
        self.tk=work.tk
        self.rolename=tk.StringVar()
        self.listbox1data=tk.StringVar()
        self.listbox2data=tk.StringVar()
        self.data=self.tk.con.sent({'modelName':'fabu','apiName':'rolefabuinfo'}).get()
        if not self.data['code'] == 200:
            tk.messagebox.showinfo('提示',self.data['info'])
            return
        self.rolenameFrame=tk.Frame(work.work)
        self.listboxFrame=tk.Frame(work.work)
        self.commitFrame=tk.Frame(work.work)
        self.rolenameFrame.pack(fill=tk.X)
        self.listboxFrame.pack(expand=True ,fill=tk.X)
        self.commitFrame.pack(expand=True ,fill=tk.X)
        tk.Label(self.rolenameFrame,text='角色名',width=5).pack(side=tk.LEFT,padx=5)
        box=ttk.Combobox(self.rolenameFrame,textvariable=self.rolename,values=tuple(self.data['data'].keys()))
        box.pack(side=tk.LEFT,padx=5)
        box.bind('<<ComboboxSelected>>',self.selectbox)
        self.listboxFrame1=tk.Frame(self.listboxFrame)
        self.adddelFrame=tk.Frame(self.listboxFrame)
        self.listboxFrame2=tk.Frame(self.listboxFrame)
        self.listboxFrame1.pack(side=tk.LEFT,expand=True,fill=tk.BOTH)
        self.adddelFrame.pack(side=tk.LEFT,padx=5,fill=tk.BOTH)
        self.listboxFrame2.pack(side=tk.LEFT,expand=True,fill=tk.BOTH)
        tk.Button(self.adddelFrame,text='增加',command=self.add).pack(pady=30)
        tk.Button(self.adddelFrame,text='删除',command=self.Del).pack(pady=1)
        tk.Button(self.commitFrame,text='提交',command=self.commit).pack()
        s1=tk.Scrollbar(self.listboxFrame1)
        s2=tk.Scrollbar(self.listboxFrame2)
        s1.pack(side=tk.RIGHT,fill=tk.Y)
        s2.pack(side=tk.RIGHT,fill=tk.Y)
        self.listbox1=tk.Listbox(self.listboxFrame1,yscrollcommand =s1.set,listvariable=self.listbox1data)
        self.listbox2=tk.Listbox(self.listboxFrame2,yscrollcommand =s2.set,listvariable=self.listbox2data)
        self.listbox1.pack(expand=True,fill=tk.BOTH)
        self.listbox2.pack(expand=True,fill=tk.BOTH)
        s1.config(command=self.listbox1.yview)
        s2.config(command=self.listbox2.yview)
        return;

    def selectbox(self,*args):
        self.fabualldata=self.tk.con.sent({'modelName':'fabu','apiName':'getallfabu'}).get()
        self.listbox1.delete(0,tk.END)
        self.listbox2.delete(0,tk.END)
        for data in self.fabualldata['data']:
            self.listbox1.insert(tk.END,data['projectname']+'_'+'测试')
            self.listbox1.insert(tk.END,data['projectname']+'_'+'正式')
        tempdata=self.rolename.get()
        envname=''

        for data in self.data['data'][tempdata]:
            try:
               envid=int(data['envid'])
            except:
                print()
            else:
                if envid == 1  :
                  envname='测试'
                elif envid == 2:
                  envname='正式'
                self.listbox2.insert(tk.END,data['projectname']+'_'+envname)
        return

    def add(self,*args):
        try:
            data=self.listbox1.get(self.listbox1.curselection())
        except:
            tk.messagebox.showinfo('提示','请选择数据')
            return

        try:
            Data=eval(self.listbox2data.get())
        except:
            self.listbox2.insert(tk.END,data)
        else:
            if not data in Data:
                self.listbox2.insert(tk.END,data)

        return

    def Del(self,*args):
        data=self.listbox2.curselection()

        if len(data) == 0:
            tk.messagebox.showinfo('提示','请选择数据')
        else:
            self.listbox2.delete(data)
            self.tk.update()
        return


    def commit(self,*args):
        # self.data  更改role 前 ,role的相关fabu
        # self.fabualldata，所有的fabu 信息
        Data=self.listbox2data.get()
        rolename=self.rolename.get()

        Sentdata={'modelName':'fabu','apiName':'rolefabuupdate'}
        tempdata=[]
        if not any(rolename):
            tk.messagebox.showinfo('提示','请选择具体角色')
            return
        roleid=self.data['data'][rolename][0]['roleid']

        try:
            data=eval(Data)
        except:
            print()
        else:
            for item in data:
                (projectname, env)=item.split('_')
                if operator.eq(env,'测试'):
                    envid=1
                elif operator.eq(env,'正式'):
                    envid=2

                for fabu in self.fabualldata['data']:
                    if operator.eq(projectname,fabu['projectname']):
                        tempdata.append({'fabuid':fabu['id'],'envid':envid})
                        break
            Sentdata['data']={'roleid':roleid,'data':tempdata}

            result=self.tk.con.sent(Sentdata).get()

            if result['code'] == 200:
                tk.messagebox.showinfo('提示','修改成功')
            else:
                tk.messagebox.showinfo('提示',result['info'])













        return