#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     18/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import tkinter as tk
from tkinter import ttk
import functools
import tkinter.messagebox


class updatePage():
    def __init__(self, work):
        work.work=tk.Frame(work.tk);
        work.work.pack(pady=30,expand=True,fill=tk.BOTH);
        ####
        self.tk=work.tk
        self.getdata()
        self.buttonFrame=tk.Frame(work.work)
        self.treeFrame=tk.Frame(work.work)
        self.buttonFrame.pack(expand=True,fill=tk.X);
        self.treeFrame.pack(fill=tk.BOTH,expand=True,pady=5);
        tk.Button(self.buttonFrame,text='修改',width=5,command=self.updatefabu).pack(side=tk.RIGHT,padx=5)
        tk.Button(self.buttonFrame,text='删除',width=5,command=self.delfabus).pack(side=tk.RIGHT,padx=5)
        scrollbar = tk.Scrollbar(self.treeFrame)
        scrollbar.pack(side=tk.RIGHT,fill=tk.Y)
        title=['id','name','git','scriptname','qaips','onlineips']
        self.tree=ttk.Treeview(self.treeFrame,columns=title,yscrollcommand=scrollbar.set,show='headings');
        self.tree.pack(side=tk.LEFT,fill=tk.BOTH,expand=True)
        for i in title:
            self.tree.column(i, width=100,anchor='center')
            self.tree.heading(i,text=i,command=functools.partial(self.treesort , i,False))

        for data in self.data['data']:
            self.tree.insert('','end',values=[data['id'], data['projectname'] ,data['git'] , data['scriptname'] ,data['qaips'],data['onlineips']])

        scrollbar.config(command=self.tree.yview)
        self.tree.bind('<ButtonRelease-1>',self.treeclick);


    def getdata(self):
        self.data=self.tk.con.sent({'modelName':'fabu','apiName':'getallfabu'}).get()
        return

    def treesort (self, col, reverse):
        '''
        表格排序
        '''
        temp=[(self.tree.set(key ,col) , key) for key in self.tree.get_children('')]
        temp.sort(reverse=reverse)

        for index,(value, key) in enumerate(temp):
            self.tree.move(key ,'',index);

        self.tree.heading(col, command=lambda:self.treesort(col, not reverse) )
        return

    def treeclick(self,envent):
        self.selectdata={}
        for item in self.tree.selection():
            #print(self.tree.item(item,'values'))
            self.selectdata[item]=self.tree.item(item,'values')
        return;

    def delfabus (self,*args):
        data=[]
        if not hasattr (self,'selectdata'):
            tkinter.messagebox.showinfo('提示','请选择数据')
            return
        elif (len(self.selectdata) == 0):
            tkinter.messagebox.showinfo('提示','请选择数据')
            return

        for item in self.selectdata.keys():
            data.append(int(self.tree.item(item,'values')[0]))
        result=self.tk.con.sent({'modelName':'fabu','apiName':'delfabus','id':data}).get()
        if result['code'] == 200:
            for item in self.selectdata.keys():
                self.tree.delete(item)
        else:
            tkinter.messagebox.showinfo('提示',result['info'])
        self.tk.update()
        self.selectdata={}

    def updatefabu(self,*args):
        id=tk.IntVar()
        name=tk.StringVar()
        git=tk.StringVar()
        scriptname=tk.StringVar()
        qaips=tk.StringVar()
        onlineips=tk.StringVar()
        Item=''
        def commit(*args):
            data={'modelName':'fabu','apiName':'updatefabu'}
            data['id']=args[0].get()
            data['name']=args[1].get()
            data['git']=args[2].get()
            data['scriptname']=args[3].get()
            data['qaips']=args[4].get()
            data['onlineips']=args[5].get()
            result=self.tk.con.sent(data).get()
            if result['code'] == 200:
                tkinter.messagebox.showinfo('提示',result['info'])
                self.updatefabupage.destroy()
                ##刷新tree
                self.tree.delete(Item)
                self.tree.insert('','end',values=[data['id'], data['name'] ,data['git'] , data['scriptname'] ,data['qaips'],data['onlineips']])
                self.tk.update()
            else:
                tkinter.messagebox.showinfo('提示',result['info'])
                self.updatefabupage.destroy()

            self.selectdata={}
            self.tk.update()
            return

        if not hasattr (self,'selectdata'):
            tkinter.messagebox.showinfo('提示','请选择数据')
            return
        elif (len(self.selectdata) == 0):
            tkinter.messagebox.showinfo('提示','请选择数据')
            return

        for item in self.selectdata.keys():
            id.set(self.tree.item(item,'values')[0])
            name.set(self.tree.item(item,'values')[1])
            git.set(self.tree.item(item,'values')[2])
            scriptname.set(self.tree.item(item,'values')[3])
            qaips.set(self.tree.item(item,'values')[4])
            onlineips.set(self.tree.item(item,'values')[5])
            Item=item
            break

        self.updatefabupage=tk.Toplevel()
        self.updatefabupage.title('更新')
        self.updatefabupage.geometry('400x300')
        self.updatefabupage.nameFrame=tk.Frame(self.updatefabupage)
        self.updatefabupage.gitFrame=tk.Frame(self.updatefabupage)
        self.updatefabupage.scriptnameFrame=tk.Frame(self.updatefabupage)
        self.updatefabupage.qaipsFrame=tk.Frame(self.updatefabupage)
        self.updatefabupage.onlineipsFrame=tk.Frame(self.updatefabupage)
        self.updatefabupage.commit=tk.Frame(self.updatefabupage)

        self.updatefabupage.nameFrame.pack(expand=True,pady=5)
        self.updatefabupage.gitFrame.pack(expand=True,pady=5)
        self.updatefabupage.scriptnameFrame.pack(expand=True,pady=5)
        self.updatefabupage.qaipsFrame.pack(expand=True,pady=5)
        self.updatefabupage.onlineipsFrame.pack(expand=True,pady=5)
        self.updatefabupage.commit.pack(expand=True,pady=5)

        tk.Label(self.updatefabupage.nameFrame,text='name',width=10).pack(side=tk.LEFT);
        tk.Entry(self.updatefabupage.nameFrame,textvariable=name).pack();
        tk.Label(self.updatefabupage.gitFrame,text='git',width=10).pack(side=tk.LEFT)
        tk.Entry(self.updatefabupage.gitFrame,textvariable=git).pack();
        tk.Label(self.updatefabupage.scriptnameFrame,text='scriptname',width=10).pack(side=tk.LEFT);
        tk.Label(self.updatefabupage.qaipsFrame,text='qaips',width=10).pack(side=tk.LEFT);
        tk.Label(self.updatefabupage.onlineipsFrame,text='onlineips',width=10).pack(side=tk.LEFT);
        tk.Entry(self.updatefabupage.scriptnameFrame,textvariable=scriptname).pack()
        tk.Entry(self.updatefabupage.qaipsFrame,textvariable=qaips).pack()
        tk.Entry(self.updatefabupage.onlineipsFrame,textvariable=onlineips).pack()
        tk.Button(self.updatefabupage.commit,text='修改提交',command=functools.partial(commit,id,name,git,scriptname,qaips,onlineips)).pack()
        return
