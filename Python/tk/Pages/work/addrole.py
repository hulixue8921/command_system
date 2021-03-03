#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     23/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import tkinter as tk
import operator

class addRolePage():
    def __init__(self,work):
        work.work=tk.Frame(work.tk)
        work.work.pack(pady=40,expand=True,fill=tk.BOTH)
        self.work=work.work
        self.tk=work.tk
        self.rolename=tk.StringVar()
        self.allfabulistbox=tk.StringVar()
        self.partfabulistbox=tk.StringVar()
        self.rolenameFrame=tk.Frame(work.work)
        self.rolenameFrame.pack(fill=tk.X)
        self.listboxFrame=tk.Frame(work.work)
        self.listboxFrame.pack(expand=True,fill=tk.X)
        self.commitFrame=tk.Frame(work.work)
        self.commitFrame.pack(expand=True,fill=tk.X)
        self.allfabulistboxFrame=tk.Frame(self.listboxFrame)
        self.allfabulistboxFrame.pack(sid=tk.LEFT,expand=True,fill=tk.BOTH)
        self.adddelFrame=tk.Frame(self.listboxFrame)
        self.adddelFrame.pack(side=tk.LEFT,fill=tk.BOTH,padx=5)
        self.partfabulistboxFrame=tk.Frame(self.listboxFrame)
        self.partfabulistboxFrame.pack(side=tk.LEFT,expand=True,fill=tk.BOTH)
        scrollbarall = tk.Scrollbar(self.allfabulistboxFrame)
        scrollbarall.pack(side=tk.RIGHT,fill=tk.Y)
        scrollbarpart = tk.Scrollbar(self.partfabulistboxFrame)
        scrollbarpart.pack(side=tk.RIGHT,fill=tk.Y)
        self.listbox1=tk.Listbox(self.allfabulistboxFrame,yscrollcommand =scrollbarall.set,listvariable=self.allfabulistbox)
        self.listbox1.pack(side=tk.LEFT,expand=True,fill=tk.BOTH)
        self.listbox2=tk.Listbox(self.partfabulistboxFrame,yscrollcommand =scrollbarpart.set,listvariable=self.partfabulistbox)
        self.listbox2.pack(side=tk.LEFT,expand=True,fill=tk.BOTH)
        tk.Label(self.rolenameFrame,text='角色名',width=5).pack(side=tk.LEFT,padx=5)
        tk.Entry(self.rolenameFrame,textvariable=self.rolename).pack(side=tk.LEFT,padx=5)
        tk.Button(self.adddelFrame,text='增加',command=self.add).pack(pady=30)
        tk.Button(self.adddelFrame,text='删除',command=self.Del).pack(pady=1)
        self.insert()
        scrollbarall.config(command=self.listbox1.yview)
        scrollbarpart.config(command=self.listbox2.yview)
        tk.Button(self.commitFrame, text='提交', command=self.commit).pack();
        return

    def commit(self,*args):
        data=self.partfabulistbox.get()
        Data=eval(data)  ##字符串转元组
        result=[]
        if any(Data) and any(self.rolename.get()):
            for d in Data:
                (projectname, env)=d.split('_')
                for x in self.data['data']:
                    envid=1;
                    if operator.eq(x['projectname'], projectname):
                        if operator.eq(env,'测试'):
                            envid=1
                        elif (operator.eq(env,'正式')):
                            envid=2
                        result.append({'fabuid':x['id'],'envid':envid})
                        break
            temp=self.tk.con.sent({'modelName':'fabu','apiName':'addrole','rolename':self.rolename.get(),'data':result}).get();
            if temp['code'] == 200:
                tk.messagebox.showinfo('提示' , '添加角色成功')
                self.rolename.set('')
            else:
                tk.messagebox.showinfo('提示',temp['info'])
            return;
        else:
            tk.messagebox.showinfo('提示','请填写角色名或请添加角色所需权限')
        return

    def add(self,*args):
        try:
            data=self.listbox1.get(self.listbox1.curselection())
        except:
            tk.messagebox.showinfo('提示','请选择数据')
            return

        try:
            Data=eval(self.partfabulistbox.get())
        except:
            self.listbox2.insert(tk.END,data)
        else:
            if not data in Data:
                self.listbox2.insert(tk.END,data)
                self.tk.update()
        return

    def Del(self,*args):
        data=self.listbox2.curselection()
        if len(data) == 0:
            tk.messagebox.showinfo('提示','请选择数据')
        else:
            self.listbox2.delete(self.listbox2.curselection())
        self.tk.update()
        return

    def insert(self):
        self.data=self.tk.con.sent({'modelName':'fabu','apiName':'getallfabu'}).get()
        if len(self.data['data']) == 0:
            return
        for data in self.data['data']:
            projectname=data['projectname']
            '''插入listbox数据'''
            self.listbox1.insert(tk.END,projectname+'_'+'测试')
            self.listbox1.insert(tk.END,projectname+'_'+'正式')
        return