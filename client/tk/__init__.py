
import tkinter
import operator;
from .func import *
from .toplevel import *

class  tk (tkinter.Tk):
    def __init__(self,client):
        super().__init__();
        self.geometry('1000x400')
        self.title('运维专用')
        self.client=client
        self.models={};

    def firstPage(self):
        self.username=tkinter.StringVar();
        self.passwd=tkinter.StringVar();
        self.Frame0=tkinter.Frame(self);
        self.Frame0.pack(expand='true');
        self.Frame1=tkinter.Frame(self.Frame0);
        self.Frame2=tkinter.Frame(self.Frame0);
        self.Frame1.pack(expand='true');
        self.Frame2.pack(expand='true',pady=10);
        tkinter.Label(self.Frame1,text="用户名").pack(side=tkinter.LEFT,fill=tkinter.X);
        tkinter.Entry(self.Frame1,textvariable=self.username).pack(side=tkinter.LEFT, padx=10)
        tkinter.Label(self.Frame2,text="密码").pack(side=tkinter.LEFT,fill=tkinter.Y);
        tkinter.Entry(self.Frame2, textvariable=self.passwd,show='*').pack(side=tkinter.LEFT,padx=10)
        tkinter.Button(self.Frame0, text="登录或注册",command=lambda:load.load(self)).pack();
        return;

    def secondPage(self,info):
        if hasattr(self, 'Frame0'):
            self.Frame0.forget();
            self.Frame1.forget();
            self.Frame2.forget();
            self.update();
            delattr(self, 'Frame0');
            delattr(self, 'Frame1');
            delattr(self, 'Frame2');

        if not hasattr(self, 'Frame3'):
            self.Frame3=tkinter.Frame();
            self.Frame3.pack(fill=tkinter.BOTH,pady=50);
            self.Frame4=tkinter.Frame(self.Frame3);
            self.Frame5=tkinter.Frame(self.Frame3);
            self.Frame4.pack(side=tkinter.LEFT);
            line=tkinter.Canvas(self.Frame3)
            line.pack(side=tkinter.LEFT);
            line.create_line(100,0,100,300,fill='black' , dash=(3,3));
            self.Frame5.pack(side=tkinter.LEFT);
        if operator.eq(info['project']['action'],'add'):
            load.addModel(self, info);
        elif operator.eq(info['project']['action'],'del'):
            load.delModel(self, info);
        return

    def thirdPage(self, info):
        load.addOrder(self,info)
        return

    def toplevel(self,info):
        self.wait_window(toplevel.toplevel(info,self));
        return

