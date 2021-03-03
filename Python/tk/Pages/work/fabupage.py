#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     09/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------

import tkinter as tk
import tkinter.ttk as ttk
import functools
import operator
import Th

class  fabupage():
    def __init__(self, work):
        #work.updateWorkPage();
        work.work=tk.Frame(work.tk);
        work.work.pack(pady=40);
        self.work=work.work;
        ####
        self.temp=[]
        self.tk=work.tk
        self.projectname=tk.StringVar();
        self.envname=tk.StringVar()
        self.gitversion=tk.StringVar()
        self.getdata()
        self.env={'1':'测试','2':'线上'}
        '''
        接受调入后台
        '''
        self.lock=Th.lock()

        self.projectnameFrame=tk.Frame(work.work)
        self.envnameFrame=tk.Frame(work.work)
        self.gitversionFrame=tk.Frame(work.work)
        self.buttonFrame=tk.Frame(work.work)
        self.projectnameFrame.pack(fill=tk.X,expand=True,pady=5)
        self.envnameFrame.pack(fill=tk.X,expand=True,pady=5)
        self.gitversionFrame.pack(fill=tk.X,expand=True,pady=5)
        self.buttonFrame.pack(fill=tk.X,expand=True,pady=5)
        tk.Label(self.projectnameFrame, text='项目名', width=5).pack(side=tk.LEFT);
        box=ttk.Combobox(self.projectnameFrame,textvariable=self.projectname,values=tuple(self.data['data'].keys()))
        box.pack(side=tk.LEFT,padx=5);
        box.bind('<<ComboboxSelected>>',self.virf);
        tk.Label(self.envnameFrame,text='环境', width=5).pack(side=tk.LEFT)
        self.box1=ttk.Combobox(self.envnameFrame,textvariable=self.envname,values=tuple(self.temp))
        self.box1.pack();
        tk.Label(self.gitversionFrame,text='版本号',width=5).pack(side=tk.LEFT)
        tk.Entry(self.gitversionFrame,textvariable=self.gitversion).pack(side=tk.LEFT,padx=5)
        tk.Button(self.buttonFrame,text='commit',command=self.commit).pack();
        return;

    def virf(self,envent):
        self.temp=[];
        self.envname.set('')
        self.gitversion.set('')
        for i in self.data['data'][self.projectname.get()]['envids']:
            self.temp.append(self.env[i]);
        self.box1.destroy();
        self.box1=ttk.Combobox(self.envnameFrame,textvariable=self.envname,values=tuple(self.temp))
        self.box1.pack(fill=tk.X,expand=True,pady=5);

        return;

    def commit(self, *args):
        projectid=self.data['data'][self.projectname.get()]['id'];
        envid=3;  #设置默认值，默认值在服务器端 是没有执行权限的
        if operator.eq(self.envname.get(),  '测试'):
            envid=1
        elif operator.eq(self.envname.get(),  '线上'):
            envid=2
        self.sentdata={'modelName':'fabu','apiName':'fabu','version':self.gitversion.get(),'envid':envid,'projectid':projectid};
        #result=self.tk.con.sent(data).get()
        self.tk.con.postSent(self.sentdata)

        Th.th(functools.partial(self.postget)).start()


    def getdata(self):
        self.data=self.tk.con.sent({'modelName':'fabu','apiName':'getfabuinfo'}).get()
        return

    def postget(self):
        self.lock.acquire()
        result=self.tk.con.postGet()
        tk.messagebox.showinfo('提示',result['info'])
        self.lock.release()


