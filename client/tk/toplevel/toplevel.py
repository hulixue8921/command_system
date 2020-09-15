#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      Administrator
#
# Created:     26/08/2020
# Copyright:   (c) Administrator 2020
# Licence:     <your licence>
#------------------------------------------------------------------------------
import tkinter
import json;
from tkinter import ttk
import operator
import functools;
import tkinter.messagebox;

class toplevel(tkinter.Toplevel):
    def __init__(self,info,selftk):
        super().__init__();
        self.ref=info['css']['data']
        self.title(self.ref['name'])
        self.post=tkinter.StringVar();
        self.tempPost={};
        self.client=selftk.client;
        self.root=selftk;
        self.css=json.loads(self.ref['css']);
        self.data=self.ref['data'];
        frame=tkinter.Frame(self);
        frame.pack(fill=tkinter.X,padx=80, pady=80);

        for i in self.css.keys():
            temp=tkinter.Frame(frame);
            temp.pack(fill=tkinter.X);
            tkinter.Label(temp,text=self.css[i]['name']).pack(side=tkinter.LEFT);
            self.tempPost[self.css[i]['name']]=tkinter.StringVar();

            if operator.eq(str(self.css[i]['data']['source']) , '1'):
                self.tempPost[self.css[i]['name']].set("请选择")
                if i in self.data.keys():
                    Values=list(self.data[i].keys());
                    Values.sort();
                    ttk.Combobox(temp,textvariable=self.tempPost[self.css[i]['name']],values=Values).pack(side=tkinter.LEFT);
                else:
                    ttk.Combobox(temp,textvariable=self.tempPost[self.css[i]['name']],values=("没有数据")).pack(side=tkinter.LEFT);

            else:
                if operator.eq(self.css[i]['name'], '参数定义'):
                    self.tempPost[self.css[i]['name']].set("样例：参数1名_属性1(0|1,k|v)-参数2名_属性2(0|1,k|v)");
                tkinter.Entry(temp,textvariable=self.tempPost[self.css[i]['name']]).pack()

        confirm=tkinter.Frame(frame)
        confirm.pack(fill=tkinter.X)
        tkinter.Button(confirm,text='确定',command=functools.partial(self.commit,self)).pack();
        return;

    def commit(self, *args):
        data={'user':{'action':'execOrder', 'username':self.root.username.get() ,'pid':self.ref['projectid'] ,'oid':self.ref['id']}}
        data['user']['data']={};

        for i in self.css.keys():
            tempValues=self.tempPost[self.css[i]['name']].get();
            if not tempValues:
                tkinter.messagebox.showinfo('message','请输入参数');
                self.destroy()
                return;
            else:
                if operator.eq(str(self.css[i]['data']['expectGet']),'k'):
                    data['user']['data'][i]=tempValues;
                elif operator.eq(str(self.css[i]['data']['expectGet']),'v'):
                    if not i in self.data.keys():
                        tkinter.messagebox.showinfo('message','输入参数错误');
                        self.destroy()
                        return;
                    if not tempValues in self.data[i].keys():
                        tkinter.messagebox.showinfo('message','输入参数错误');
                        self.destroy()
                        return
                    else:
                        data['user']['data'][i]=self.data[i][tempValues];
        print(data);
        self.client.sent(data)
        self.destroy()
        return;

