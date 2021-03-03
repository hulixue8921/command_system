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
import tkinter.messagebox


class addfabu():
    def __init__(self,work):
        #work.updateWorkPage();
        work.work=tk.Frame(work.tk);
        work.work.pack(pady=30);
        ####
        self.tk=work.tk;
        self.name=tk.StringVar();
        self.git=tk.StringVar();
        self.scriptname=tk.StringVar()
        self.qaips=tk.StringVar()
        self.onlineips=tk.StringVar()
        self.nameFrame=tk.Frame(work.work)
        self.gitFrame=tk.Frame(work.work)
        self.scriptnameFrame=tk.Frame(work.work)
        self.qaipsFrame=tk.Frame(work.work)
        self.onlineipsFrame=tk.Frame(work.work)
        self.commitFrame=tk.Frame(work.work)
        self.nameFrame.pack(fill=tk.X,pady=5,expand=True);
        self.gitFrame.pack(fill=tk.X,pady=5,expand=True);
        self.scriptnameFrame.pack(fill=tk.X,pady=5,expand=True);
        self.qaipsFrame.pack(fill=tk.X,pady=5,expand=True);
        self.onlineipsFrame.pack(fill=tk.X,pady=5,expand=True);
        self.commitFrame.pack();
        self.scriptname.set('fabu.sh')
        tk.Label(self.nameFrame,text='名字',width=10).pack(side=tk.LEFT);
        tk.Entry(self.nameFrame,textvariable=self.name).pack();
        tk.Label(self.gitFrame,text='git',width=10).pack(side=tk.LEFT)
        tk.Entry(self.gitFrame, textvariable=self.git).pack();
        tk.Label(self.scriptnameFrame, text='发布脚本名',width=10).pack(side=tk.LEFT)
        tk.Entry(self.scriptnameFrame,textvariable=self.scriptname).pack();
        tk.Label(self.qaipsFrame,text='测试地址',width=10).pack(side=tk.LEFT)
        tk.Entry(self.qaipsFrame,textvariable=self.qaips).pack();
        tk.Label(self.onlineipsFrame,text='线上地址',width=10).pack(side=tk.LEFT);
        tk.Entry(self.onlineipsFrame,textvariable=self.onlineips).pack();
        tk.Button(self.commitFrame,text='commit',command=self.commit).pack();
        return;

    def commit(self,*args):
        data={'modelName':'fabu','apiName':'addfabu','name':self.name.get(),'git':self.git.get(),'scriptname':self.scriptname.get(),'qaips':self.qaips.get(),'onlineips':self.onlineips.get()};
        result=self.tk.con.sent(data).get()
        if result['code'] == 200:
            self.name.set('')
            self.git.set('')
            self.onlineips.set('')
            self.qaips.set('')
            tkinter.messagebox.showinfo('提示','执行成功')
        else:
            tkinter.messagebox.showinfo('提示',result['info'])




