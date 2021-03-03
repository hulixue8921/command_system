#-------------------------------------------------------------------------------
# Name:        模块1
# Purpose:
#
# Author:      Administrator
#
# Created:     08/02/2021
# Copyright:   (c) Administrator 2021
# Licence:     <your licence>
#-------------------------------------------------------------------------------


import tkinter;
import tkinter.ttk as ttk;
import functools;
from .fabupage import fabupage;
from .rollback import rollbackpage;
from .addfabu import addfabu;
from .updatepage import updatePage
from .addrole  import addRolePage
from .rolefabu import rolefabuPage
from .roleuser import roleuserPage

class WorkPage():
    def __init__ (self, tk):
        self.tk=tk
        self.lead=tkinter.Frame(self.tk)
        self.work=tkinter.Frame(self.tk)
        self.lead.pack(expand=0,side=tkinter.LEFT,fill=tkinter.Y,padx=10)
        self.work.pack(expand=True,side=tkinter.LEFT,fill=tkinter.Y)

        '''
        设置表格的高度
        '''
        s=ttk.Style()
        s.configure('Treeview' ,rowheight=32)

        tree=ttk.Treeview(self.lead);
        tree.pack(side=tkinter.LEFT,pady=10,fill=tkinter.Y,expand=True);
        tree.bind('<<TreeviewSelect>>', self.fun);
        tree.tag_configure('title' ,font='Arial 16')
        tree.tag_configure('title1' , font='Arial 13')

        fabunode=tree.insert("",0,'迭代中心',text="迭代中心",tags=('title'));
        tree.insert(fabunode,'1','发布',text='发布',tags=('title1'));
        tree.insert(fabunode,'2','回滚',text='回滚',tags=('title1'));
        fabucms=tree.insert(fabunode,'3','fabu_cms',text='fabu_cms',tags=('title1'));
        fabucms1=tree.insert(fabucms,'0','发布管理',text='发布管理',tags=());
        fabucms2=tree.insert(fabucms,'1','角色管理',text='角色管理',tags=());
        tree.insert(fabucms1,'0','增加fabu',text='增加fabu',tags=())
        tree.insert(fabucms1,'1','修改或者删除fabu',text='修改或者删除fabu',tags=())
        tree.insert(fabucms2,'0','添加角色',text='添加角色',tags=())
        tree.insert(fabucms2,'1','修改角色权限',text='修改角色权限',tags=())
        tree.insert(fabucms2,'2','修改角色用户',text='修改角色用户',tags=())
        return;

    def fun (self,event):
        data=event.widget.selection();
        fun={'发布':functools.partial(fabupage,self) ,'回滚':functools.partial(rollbackpage,self),'增加fabu':functools.partial(addfabu,self),'修改或者删除fabu':functools.partial(updatePage,self),'添加角色':functools.partial(addRolePage,self),'修改角色权限':functools.partial(rolefabuPage,self),'修改角色用户':functools.partial(roleuserPage,self)}
        print(data);
        if data[0] in fun:
            self.updateWorkPage();
            fun[data[0]]();
        else:
            return;

        return

    def updateWorkPage(self):
        for w in self.work.winfo_children():
            w.destroy();
            w.pack_forget();
        self.work.destroy();
        self.work.pack_forget();
        self.tk.update();
        return;