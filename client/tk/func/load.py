#-------------------------------------------------------------------------------
# Name:        module1
# Purpose:
#
# Author:      Administrator
#
# Created:     08/06/2020
# Copyright:   (c) Administrator 2020
# Licence:     <your licence>
#-------------------------------------------------------------------------------
import tkinter
import functools

def load(self):
    username=self.username.get();
    passwd=self.passwd.get();
    if len(username) == 0:
        self.client.message('提示',"缺少账户名")
        return
    if len(passwd) == 0:
        self.client.message('提示',"缺少密码")
    data={'user':{'action':'load','username':username,'passwd':passwd}};
    self.client.sent(data);


def addModel(self ,info):
    self.models[info['project']['data']['name']]=tkinter.Button(self.Frame4 ,text=info['project']['data']['name'],width=15)
    self.models[info['project']['data']['name']].bind(sequence='<Button-1>',func=functools.partial(getOrder, self,info['project']['data']['id']));
    self.models[info['project']['data']['name']].pack();
    return;

def delModel(self ,info):
    self.models[info['project']['data']['name']].forget();
    return;

def addOrder(self,info):
    self.Frame5.forget();
    self.update;
    delattr(self ,'Frame5');
    self.Frame5=tkinter.Frame(self.Frame3);
    self.Frame5.pack(side=tkinter.LEFT);

    for ref in info['order']['data']:
        button=tkinter.Button(self.Frame5 ,text=ref['name'],width=15)
        button.bind(sequence='<Button-1>',func=functools.partial(getOrderInfo, self,ref['id'], ref['projectid']));
        button.pack();
    return;


def getOrder(*args):
    self=args[0]
    pid=args[1]
    data={'user':{'action':'getOrder', 'username':self.username.get() ,'pid':pid}}
    self.client.sent(data)
    return

def getOrderInfo(*args):
    self=args[0]
    oid=args[1]
    pid=args[2]
    data={'user':{'action':'getOrderCssData', 'username':self.username.get() ,'pid':pid ,'oid':oid}}
    self.client.sent(data)
    return