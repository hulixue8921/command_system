#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     26/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import tkinter as tk
import tkinter.ttk as ttk
import operator

class roleuserPage():
    def __init__(self,work):
        work.work=tk.Frame(work.tk)
        work.work.pack(pady=40,expand=True,fill=tk.BOTH)
        self.work=work.work
        self.tk=work.tk
        self.rolename=tk.StringVar()
        self.listbox1data=tk.StringVar()
        self.listbox2data=tk.StringVar()
        if not self.getdata():
            return
        self.rolenameFrame=tk.Frame(work.work)
        self.listboxFrame=tk.Frame(work.work)
        self.commitFrame=tk.Frame(work.work)
        self.rolenameFrame.pack(fill=tk.X)
        self.listboxFrame.pack(expand=True ,fill=tk.X)
        self.commitFrame.pack(expand=True ,fill=tk.X)
        tk.Label(self.rolenameFrame,text='角色名',width=5).pack(side=tk.LEFT,padx=5)
        box=ttk.Combobox(self.rolenameFrame,textvariable=self.rolename,values=tuple(self.roledata['data'].keys()))
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

        return
    def getdata(self):
        self.roledata=self.tk.con.sent({'modelName':'fabu','apiName':'roleuserinfo'}).get()
        self.userdata=self.tk.con.sent({'modelName':'fabu','apiName':'userinfo'}).get()
        if not self.roledata['code'] == 200:
            tk.messagebox.showinfo('提示',self.roledata['info'])
            return

        if not self.userdata['code'] == 200:
            tk.messagebox.showinfo('提示',self.roledata['info'])
            return
        return 1

    def selectbox(self,*args):
        self.listbox2.delete(0,tk.END)
        self.listbox1.delete(0,tk.END)
        for item in self.roledata['data'][self.rolename.get()]:
            self.listbox2.insert(tk.END,item['uname'])

        for item in self.userdata['data']:
            self.listbox1.insert(tk.END,item['uname'])
        return

    def add (self, *args):
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

    def  Del(self,*args):
        data=self.listbox2.curselection()
        if len(data) == 0:
            tk.messagebox.showinfo('提示','请选择数据')
        else:
            self.listbox2.delete(data)
            self.tk.update()
        return

    def commit(self,*args):
        Data=self.listbox2data.get()
        rolename=self.rolename.get()
        tempdata=[]

        Sentdata={'modelName':'fabu','apiName':'roleuserupdate'}
        if not any(rolename):
            tk.messagebox.showinfo('提示','请选择具体角色')
            return
        roleid=self.roledata['data'][rolename][0]['rid']

        try:
            data=eval(Data)
        except:
            print()
        else:
            for uname in data:
                for item in self.userdata['data']:
                    if operator.eq(item['uname'] ,uname):
                        tempdata.append(item['uid'])

        Sentdata['data']={'roleid':roleid,'data':tempdata}
        print(Sentdata)
        result=self.tk.con.sent(Sentdata).get()

        if result['code'] == 200:
            tk.messagebox.showinfo('提示','修改成功')
        else:
            tk.messagebox.showinfo('提示',result['info'])
        return
